//
//  QueryKey.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 11.01.2025.
//

import Foundation
import SwiftUI
import Toasts

// MARK: - Core Types

struct QueryKey: Hashable {
    let components: [AnyHashable]
    
    init(_ components: AnyHashable...) {
        self.components = components
    }
    
    init(_ component: AnyHashable) {
        self.components = [component]
    }
    
    /// Custom comparison for prefix matching
    func matches(_ other: QueryKey) -> Bool {
        guard components.count >= other.components.count else { return false }
        return zip(components.prefix(other.components.count), other.components)
            .allSatisfy { $0.0 == $0.1 }
    }
}

enum LoadingState<T> {
    case idle
    case loading
    case success(T)
    case error(Error)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var value: T? {
        if case .success(let value) = self { return value }
        return nil
    }
    
    var error: Error? {
        if case .error(let error) = self { return error }
        return nil
    }
}

struct PaginationParams: Equatable {
    let page: Int
    let pageSize: Int
}

struct QueryPage<T> {
    let items: [T]
    let totalPages: Int
    let currentPage: Int
    let hasNextPage: Bool
}

// MARK: - Errors

enum QueryError: LocalizedError {
    case observerAlreadyRegistered
    case observerNotFound
    case cacheExpired
    case invalidCacheType
    case operationCancelled
    
    var errorDescription: String? {
        switch self {
        case .observerAlreadyRegistered:
            return "Observer is already registered for this query"
        case .observerNotFound:
            return "Observer not found"
        case .cacheExpired:
            return "Cache entry has expired"
        case .invalidCacheType:
            return "Invalid cache type"
        case .operationCancelled:
            return "Operation was cancelled"
        }
    }
}
    
// MARK: - Observer Protocol

protocol QueryObserver: AnyObject {
    var observerId: UUID { get }
    func onQueryInvalidated(key: QueryKey)
}

// MARK: - Query Client

actor QueryClient {
    static let shared = QueryClient()
    
    private struct CacheEntry {
        let value: Any
        let timestamp: Date
        let expirationInterval: TimeInterval
        
        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > expirationInterval
        }
    }
    
    private var cache: [QueryKey: CacheEntry] = [:]
    private var observers: [QueryKey: [UUID: WeakObserver]] = [:]
    private let defaultCacheExpiration: TimeInterval = 300 // 5 minutes
    
    private class WeakObserver {
        weak var observer: QueryObserver?
        
        init(_ observer: QueryObserver) {
            self.observer = observer
        }
    }
    
    // MARK: - Cache Management
    
    func setCachedValue<T>(_ value: T, forKey key: QueryKey, expirationInterval: TimeInterval? = nil) {
        let entry = CacheEntry(
            value: value,
            timestamp: Date(),
            expirationInterval: expirationInterval ?? defaultCacheExpiration
        )
        cache[key] = entry
    }
    
    func getCachedValue<T>(forKey key: QueryKey) throws -> T {
        guard let entry = cache[key] else {
            throw QueryError.invalidCacheType
        }
        
        if entry.isExpired {
            cache.removeValue(forKey: key)
            throw QueryError.cacheExpired
        }
        
        guard let value = entry.value as? T else {
            throw QueryError.invalidCacheType
        }
        
        return value
    }
    
    func cleanExpiredCache() {
        cache = cache.filter { !$1.isExpired }
    }
    
    // MARK: - Observer Management
    
    func addObserver(_ observer: QueryObserver, for key: QueryKey) throws {
        cleanupObservers(for: key)
        
        if observers[key]?[observer.observerId] != nil {
            throw QueryError.observerAlreadyRegistered
        }
        
        observers[key, default: [:]][observer.observerId] = WeakObserver(observer)
    }
    
    func removeObserver(_ observer: QueryObserver, for key: QueryKey) throws {
        guard observers[key]?[observer.observerId] != nil else {
            throw QueryError.observerNotFound
        }
        
        removeObserverById(observer.observerId, for: key)
    }
    
    nonisolated func removeObserverSync(_ observerId: UUID, for key: QueryKey) {
        Task {
            await removeObserverById(observerId, for: key)
        }
    }
    
    func removeObserverById(_ observerId: UUID, for key: QueryKey) {
        observers[key]?.removeValue(forKey: observerId)
        if observers[key]?.isEmpty == true {
            observers.removeValue(forKey: key)
        }
    }
    
    private func cleanupObservers(for key: QueryKey) {
        observers[key] = observers[key]?.filter { _, weakObserver in
            weakObserver.observer != nil
        }
        
        if observers[key]?.isEmpty == true {
            observers.removeValue(forKey: key)
        }
    }
    
    // MARK: - Query Invalidation
    
    func invalidateQueries(matching key: QueryKey) async {
        let invalidatedKeys = cache.keys.filter { $0.matches(key) }
        for key in invalidatedKeys {
            cache.removeValue(forKey: key)
        }
        await notifyObservers(for: key)
    }
    
    private func notifyObservers(for key: QueryKey) async {
        for (observerKey, keyObservers) in observers where key.matches(observerKey) {
            cleanupObservers(for: observerKey)
            
            for (_, weakObserver) in keyObservers {
                await MainActor.run {
                    weakObserver.observer?.onQueryInvalidated(key: key)
                }
            }
        }
    }
}

// MARK: - Query

@MainActor
class Query<T>: ObservableObject, QueryObserver {
    let observerId = UUID()
    @Published private(set) var state: LoadingState<T> = .idle
    
    private let queryClient: QueryClient
    private let queryKey: QueryKey
    private let queryFn: () async throws -> T
    private var currentTask: Task<Void, Never>?
    
    private var onSuccess: ((T) -> Void)?
    private var onError: ((Error) -> Void)?
    
    init(
        queryKey: QueryKey,
        queryFn: @escaping () async throws -> T,
        queryClient: QueryClient = .shared,
        onSuccess: ((T) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        self.queryKey = queryKey
        self.queryFn = queryFn
        self.queryClient = queryClient
        self.onSuccess = onSuccess
        self.onError = onError
        
        Task {
            try? await queryClient.addObserver(self, for: queryKey)
            await execute()
        }
    }
    
    deinit {
        currentTask?.cancel()
        queryClient.removeObserverSync(observerId, for: queryKey)
    }
    
    func onSuccess(_ handler: @escaping (T) -> Void) -> Self {
        onSuccess = handler
        // If we already have a success value, call the handler
        if case .success(let value) = state {
            handler(value)
        }
        return self
    }
    
    func onError(_ handler: @escaping (Error) -> Void) -> Self {
        onError = handler
        // If we already have an error, call the handler
        if case .error(let error) = state {
            handler(error)
        }
        return self
    }
    
    nonisolated func onQueryInvalidated(key: QueryKey) {
        Task { @MainActor [weak self] in
            await self?.execute()
        }
    }
    
    func execute() async {
        guard !state.isLoading else { return }
        
        currentTask?.cancel()
        currentTask = Task { [weak self] in
            guard let self = self else { return }
            
            self.state = .loading
            
            do {
                if let cached = try? await self.queryClient.getCachedValue(forKey: self.queryKey) as T {
                    self.state = .success(cached)
                    self.onSuccess?(cached)
                    return
                }
                
                try Task.checkCancellation()
                let result = try await self.queryFn()
                try Task.checkCancellation()
                
                await self.queryClient.setCachedValue(result, forKey: self.queryKey)
                self.state = .success(result)
                self.onSuccess?(result)
            } catch is CancellationError {
                let error = QueryError.operationCancelled
                self.state = .error(error)
                self.onError?(error)
            } catch {
                self.state = .error(error)
                self.onError?(error)
            }
        }
        
        await currentTask?.value
    }
    
    func invalidate() async {
        await queryClient.invalidateQueries(matching: queryKey)
    }
}

@MainActor
class PaginatedQuery<T>: ObservableObject {
    @Published private(set) var state: LoadingState<QueryPage<T>> = .idle
    
    private let queryClient: QueryClient
    private let queryKey: QueryKey
    private let queryFn: (PaginationParams) async throws -> QueryPage<T>
    private var activeFetches: Set<Int> = []
    private var currentTask: Task<Void, Never>?
    
    private var onSuccess: ((QueryPage<T>) -> Void)?
    private var onError: ((Error) -> Void)?
    
    init(
        queryKey: QueryKey,
        queryFn: @escaping (PaginationParams) async throws -> QueryPage<T>,
        queryClient: QueryClient = .shared,
        onSuccess: ((QueryPage<T>) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        self.queryKey = queryKey
        self.queryFn = queryFn
        self.queryClient = queryClient
        self.onSuccess = onSuccess
        self.onError = onError
    }
    
    deinit {
        currentTask?.cancel()
    }
    
    func onSuccess(_ handler: @escaping (QueryPage<T>) -> Void) -> Self {
        onSuccess = handler
        if case .success(let value) = state {
            handler(value)
        }
        return self
    }
    
    func onError(_ handler: @escaping (Error) -> Void) -> Self {
        onError = handler
        if case .error(let error) = state {
            handler(error)
        }
        return self
    }
    
    func fetchPage(page: Int, pageSize: Int) async {
        guard !activeFetches.contains(page) else { return }
        
        currentTask?.cancel()
        currentTask = Task { [weak self] in
            guard let self = self else { return }
            
            self.activeFetches.insert(page)
            defer { self.activeFetches.remove(page) }
            
            let paginationParams = PaginationParams(page: page, pageSize: pageSize)
            let pageQueryKey = QueryKey(self.queryKey.components + [page])
            
            self.state = .loading
            
            do {
                if let cached = try? await self.queryClient.getCachedValue(forKey: pageQueryKey) as QueryPage<T> {
                    self.state = .success(cached)
                    self.onSuccess?(cached)
                    return
                }
                
                try Task.checkCancellation()
                let result = try await self.queryFn(paginationParams)
                try Task.checkCancellation()
                
                await self.queryClient.setCachedValue(result, forKey: pageQueryKey)
                self.state = .success(result)
                self.onSuccess?(result)
            } catch is CancellationError {
                let error = QueryError.operationCancelled
                self.state = .error(error)
                self.onError?(error)
            } catch {
                self.state = .error(error)
                self.onError?(error)
            }
        }
        
        await currentTask?.value
    }
}

// MARK: - Mutation

@MainActor
class Mutation<Input, Output>: ObservableObject {
    @Published private(set) var state: LoadingState<Output> = .idle
    
    private let queryClient: QueryClient
    private let mutationFn: (Input) async throws -> Output
    private let invalidateKeys: [QueryKey]
    private var currentTask: Task<Void, Never>?
    
    private var onSuccess: ((Output) -> Void)?
    private var onError: ((Error) -> Void)?
    
    init(
        queryClient: QueryClient = .shared,
        invalidateKeys: [QueryKey] = [],
        mutationFn: @escaping (Input) async throws -> Output,
        onSuccess: ((Output) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        self.queryClient = queryClient
        self.invalidateKeys = invalidateKeys
        self.mutationFn = mutationFn
        self.onSuccess = onSuccess
        self.onError = onError
    }
    
    deinit {
        currentTask?.cancel()
    }
    
    func onSuccess(_ handler: @escaping (Output) -> Void) -> Self {
        onSuccess = handler
        if case .success(let value) = state {
            handler(value)
        }
        return self
    }
    
    func onError(_ handler: @escaping (Error) -> Void) -> Self {
        onError = handler
        if case .error(let error) = state {
            handler(error)
        }
        return self
    }
    
    func execute(_ input: Input) async {
        currentTask?.cancel()
        currentTask = Task { [weak self] in
            guard let self = self else { return }
            
            self.state = .loading
            
            do {
                try Task.checkCancellation()
                let result = try await self.mutationFn(input)
                try Task.checkCancellation()
                
                self.state = .success(result)
                self.onSuccess?(result)
                
                for key in self.invalidateKeys {
                    await self.queryClient.invalidateQueries(matching: key)
                }
            } catch is CancellationError {
                let error = QueryError.operationCancelled
                self.state = .error(error)
                self.onError?(error)
            } catch {
                self.state = .error(error)
                self.onError?(error)
            }
        }
        
        await currentTask?.value
    }
    
    func execute(
        _ input: Input,
        onSuccess: ((Output) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil,
        onLoading: (() -> Void)? = nil
    ) {
        currentTask?.cancel()
        currentTask = Task { [weak self] in
            guard let self = self else { return }
            
            self.state = .loading
            onLoading?()
            
            do {
                try Task.checkCancellation()
                let result = try await self.mutationFn(input)
                try Task.checkCancellation()
                
                self.state = .success(result)
                onSuccess?(result)
                
                for key in self.invalidateKeys {
                    await self.queryClient.invalidateQueries(matching: key)
                }
            } catch is CancellationError {
                let error = QueryError.operationCancelled
                self.state = .error(error)
                onError?(error)
            } catch {
                self.state = .error(error)
                onError?(error)
            }
        }
    }
    
    func execute(
        _ input: Input,
        presenting toast: PresentToastAction,
        successMessage: String,
        errorTransform: @escaping (Error) -> String = { $0.localizedDescription },
        onSuccess: ((Output) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil,
        onLoading: (() -> Void)? = nil
    ) {
        execute(
            input,
            onSuccess: { output in
                let toastValue = ToastValue(
                    icon: Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green),
                    message: successMessage
                )
                toast(toastValue)
                onSuccess?(output)
            },
            onError: { error in
                let toastValue = ToastValue(
                    icon: Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red),
                    message: errorTransform(error)
                )
                toast(toastValue)
                onError?(error)
            },
            onLoading: onLoading
        )
    }
}


// MARK: - Query Combining

protocol Queryable {
    associatedtype Output
    var state: LoadingState<Output> { get }
}

protocol QueryInvalidatable {
    func invalidate() async
}

protocol QueryProtocol: Queryable, QueryInvalidatable {}

extension Query: QueryProtocol {}

@MainActor
func combineQueries<T: Queryable>(_ queries: T...) -> LoadingState<[T.Output]> {
    for query in queries {
        if case .error(let error) = query.state {
            return .error(error)
        }
    }
    
    if queries.contains(where: {
        if case .loading = $0.state { return true }
        return false
    }) {
        return .loading
    }
    
    let values = queries.compactMap { query -> T.Output? in
        if case .success(let value) = query.state {
            return value
        }
        return nil
    }
    
    if values.count == queries.count {
        return .success(values)
    }
    
    return .idle
}

class AnyQuery: QueryProtocol {
    typealias Output = Any
    
    private let _state: () -> LoadingState<Any>
    private let _invalidate: () async -> Void
    
    var state: LoadingState<Any> {
        _state()
    }
    
    init<Q: QueryProtocol>(_ query: Q) {
        self._state = {
            switch query.state {
            case .idle:
                return .idle
            case .loading:
                return .loading
            case .success(let value):
                return .success(value)
            case .error(let error):
                return .error(error)
            }
        }
        self._invalidate = { await query.invalidate() }
    }
    
    func invalidate() async {
        await _invalidate()
    }
}

@MainActor
func combineQueries(_ queries: [AnyQuery]) -> LoadingState<[Any]> {
    for query in queries {
        if case .error(let error) = query.state {
            return .error(error)
        }
    }
    
    if queries.contains(where: {
        if case .loading = $0.state { return true }
        return false
    }) {
        return .loading
    }
    
    let values = queries.compactMap { query -> Any? in
        if case .success(let value) = query.state {
            return value
        }
        return nil
    }
    
    if values.count == queries.count {
        return .success(values)
    }
    
    return .idle
}

func combineQueries<T1: Queryable, T2: Queryable>(
    _ q1: T1,
    _ q2: T2
) -> LoadingState<(T1.Output, T2.Output)> {
    switch (q1.state, q2.state) {
    case (.success(let v1), .success(let v2)):
        return .success((v1, v2))
    case (.error(let error), _), (_, .error(let error)):
        return .error(error)
    case (.loading, _), (_, .loading):
        return .loading
    default:
        return .idle
    }
}

func combineQueries<T1: Queryable, T2: Queryable, T3: Queryable>(
    _ q1: T1,
    _ q2: T2,
    _ q3: T3
) -> LoadingState<(T1.Output, T2.Output, T3.Output)> {
    switch (q1.state, q2.state, q3.state) {
    case (.success(let v1), .success(let v2), .success(let v3)):
        return .success((v1, v2, v3))
    case (.error(let error), _, _), (_, .error(let error), _), (_, _, .error(let error)):
        return .error(error)
    case (.loading, _, _), (_, .loading, _), (_, _, .loading):
        return .loading
    default:
        return .idle
    }
}

struct CombinedQueriesView<Content: View, SuccessContent: View>: View {
    let queries: [AnyQuery]
    let content: Content
    let successContent: ([Any]) -> SuccessContent
    
    init(
        queries: [any QueryProtocol],
        content: Content,
        successContent: @escaping ([Any]) -> SuccessContent
    ) {
        self.queries = queries.map { query in
            AnyQuery(query)
        }
        self.content = content
        self.successContent = successContent
    }
    
    var body: some View {
        Group {
            switch combineQueries(queries) {
            case .success(let values):
                successContent(values)
            case .error(let error):
                ErrorView(error: error.localizedDescription) {
                    Task {
                        for query in queries {
                            await query.invalidate()
                        }
                    }
                }
            case .loading, .idle:
                content
            }
        }
    }
}

extension View {
    func withCombinedQueries<Content: View, SuccessContent: View>(
        _ queries: [any QueryProtocol],
        @ViewBuilder loading: () -> Content,
        @ViewBuilder success: @escaping ([Any]) -> SuccessContent
    ) -> some View {
        CombinedQueriesView(
            queries: queries,
            content: loading(),
            successContent: success
        )
    }
}

extension View {
    func withCombinedQueries<Q1: QueryProtocol, Q2: QueryProtocol, Content: View, SuccessContent: View>(
        _ query1: Q1,
        _ query2: Q2,
        @ViewBuilder loading: () -> Content,
        @ViewBuilder success: @escaping (Q1.Output, Q2.Output) -> SuccessContent
    ) -> some View {
        CombinedQueriesView(
            queries: [query1, query2],
            content: loading(),
            successContent: { values in
                guard
                    let v1 = values[0] as? Q1.Output,
                    let v2 = values[1] as? Q2.Output
                else {
                    return success(values[0] as! Q1.Output, values[1] as! Q2.Output)
                }
                return success(v1, v2)
            }
        )
    }
}

// MARK: - Helpers

struct QueryView<Output, LoadingContent: View, SuccessContent: View, ErrorContent: View>: View {
    let query: Query<Output>
    let content: LoadingContent
    let successContent: (Output) -> SuccessContent
    let errorContent: (Error) -> ErrorContent
    
    var body: some View {
        Group {
            switch query.state {
            case .success(let value):
                successContent(value)
            case .error(let error):
                errorContent(error)
            case .loading, .idle:
                content
            }
        }
    }
}

extension View {
    func withQuery<Output, LoadingContent: View, SuccessContent: View, ErrorContent: View>(
        _ query: Query<Output>,
        @ViewBuilder loading: () -> LoadingContent,
        @ViewBuilder success: @escaping (Output) -> SuccessContent,
        @ViewBuilder error: @escaping (Error) -> ErrorContent
    ) -> some View {
        QueryView(
            query: query,
            content: loading(),
            successContent: success,
            errorContent: error
        )
    }
    
    func withQueryError<Output, LoadingContent: View, SuccessContent: View>(
        _ query: Query<Output>,
        @ViewBuilder loading: () -> LoadingContent,
        @ViewBuilder success: @escaping (Output) -> SuccessContent
    ) -> some View {
        QueryView(
            query: query,
            content: loading(),
            successContent: success,
            errorContent: { error in
                ErrorView(error: error.localizedDescription) {
                    Task {
                        await query.invalidate()
                    }
                }
            }
        )
    }
    
    // Convenience method with ProgressView
    func withQueryProgress<Output, SuccessContent: View>(
        _ query: Query<Output>,
        @ViewBuilder success: @escaping (Output) -> SuccessContent
    ) -> some View {
        withQueryError(query) {
            ProgressView()
        } success: { value in
            success(value)
        }
    }
}

struct MutationView<Input, Output, LoadingContent: View, SuccessContent: View>: View {
    let mutation: Mutation<Input, Output>
    let content: LoadingContent
    let successContent: (Output) -> SuccessContent
    
    var body: some View {
        Group {
            switch mutation.state {
            case .success(let value):
                successContent(value)
            case .error(let error):
                ErrorView(error: error.localizedDescription) {
                    // No invalidate for mutations
                }
            case .loading, .idle:
                content
            }
        }
    }
}

extension View {
    func withMutation<Input, Output, LoadingContent: View, SuccessContent: View>(
        _ mutation: Mutation<Input, Output>,
        @ViewBuilder loading: () -> LoadingContent,
        @ViewBuilder success: @escaping (Output) -> SuccessContent
    ) -> some View {
        MutationView(
            mutation: mutation,
            content: loading(),
            successContent: success
        )
    }
    
    func withMutationProgress<Input, Output, SuccessContent: View>(
        _ mutation: Mutation<Input, Output>,
        @ViewBuilder success: @escaping (Output) -> SuccessContent
    ) -> some View {
        withMutation(mutation) {
            ProgressView()
        } success: { value in
            success(value)
        }
    }
    
    // With toast error handling
    func withMutationToast<Input, Output, LoadingContent: View, SuccessContent: View>(
        _ mutation: Mutation<Input, Output>,
        toast: @escaping (ToastValue) -> Void,
        @ViewBuilder loading: () -> LoadingContent,
        @ViewBuilder success: @escaping (Output) -> SuccessContent
    ) -> some View {
        Group {
            switch mutation.state {
            case .success(let value):
                success(value)
            case .error(let error):
                loading()
                    .onAppear {
                        let toastValue = ToastValue(
                            icon: Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red),
                            message: error.localizedDescription
                        )
                        toast(toastValue)
                    }
            case .loading, .idle:
                loading()
            }
        }
    }
}
