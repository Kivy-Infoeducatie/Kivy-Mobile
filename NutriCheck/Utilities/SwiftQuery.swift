//
//  QueryKey.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 11.01.2025.
//

import Foundation

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
}

// MARK: OLD

/*
 import Foundation

 struct QueryKey: Hashable {
     let components: [AnyHashable]
    
     init(_ components: AnyHashable...) {
         self.components = components
     }
    
     init(_ component: AnyHashable) {
         self.components = [component]
     }
 }

 enum LoadingState<T> {
     case idle
     case loading
     case success(T)
     case error(Error)
 }

 struct PaginationParams {
     var page: Int
     var pageSize: Int
 }

 struct QueryPage<T> {
     let items: [T]
     let totalPages: Int
     let currentPage: Int
     let hasNextPage: Bool
 }

 protocol QueryObserver: AnyObject {
     var observerId: UUID { get }
     func onQueryInvalidated(key: QueryKey)
 }

 enum QueryError: Error {
     case observerAlreadyRegistered
     case observerNotFound
 }

 actor QueryClient {
     static let shared = QueryClient()
    
     private var cache: [QueryKey: (data: Any, timestamp: Date)] = [:]
     private var observers: [QueryKey: [UUID: WeakObserver]] = [:]
    
     func invalidateQueries(matching key: QueryKey) async {
         cache = cache.filter { !$0.key.components.starts(with: key.components) }
         notifyObservers(for: key)
     }
    
     private class WeakObserver {
         weak var observer: QueryObserver?
        
         init(_ observer: QueryObserver) {
             self.observer = observer
         }
     }
    
     func addObserver(_ observer: QueryObserver, for key: QueryKey) throws {
         cleanupObservers(for: key)
        
         if observers[key]?[observer.observerId] != nil {
             throw QueryError.observerAlreadyRegistered
         }
        
         observers[key, default: [:]][observer.observerId] = WeakObserver(observer)
     }
    
     func removeObserverById(_ observerId: UUID, for key: QueryKey) {
         observers[key]?.removeValue(forKey: observerId)
         if observers[key]?.isEmpty == true {
             observers.removeValue(forKey: key)
         }
     }
    
     func removeObserver(_ observer: QueryObserver, for key: QueryKey) throws {
         guard observers[key]?[observer.observerId] != nil else {
             throw QueryError.observerNotFound
         }
        
         observers[key]?.removeValue(forKey: observer.observerId)
         if observers[key]?.isEmpty == true {
             observers.removeValue(forKey: key)
         }
     }
    
     private func notifyObservers(for key: QueryKey) {
         cleanupObservers(for: key)
        
         for (observerKey, keyObservers) in observers {
             if key.components.starts(with: observerKey.components) {
                 for (_, weakObserver) in keyObservers {
                     Task { @MainActor in
                         weakObserver.observer?.onQueryInvalidated(key: key)
                     }
                 }
             }
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
    
     func setCachedValue<T>(_ value: T, forKey key: QueryKey) {
         cache[key] = (value, Date())
     }
    
     func getCachedValue<T>(forKey key: QueryKey) -> T? {
         guard let (value, _) = cache[key],
               let typedValue = value as? T
         else {
             return nil
         }
         return typedValue
     }
 }

 @MainActor
 class Query<T>: ObservableObject, QueryObserver {
     let observerId = UUID()
     @Published private(set) var state: LoadingState<T> = .idle
     private let queryClient: QueryClient
     private let queryKey: QueryKey
     private let queryFn: () async throws -> T
    
     init(
         queryKey: QueryKey,
         queryFn: @escaping () async throws -> T,
         queryClient: QueryClient = .shared
     ) {
         self.queryKey = queryKey
         self.queryFn = queryFn
         self.queryClient = queryClient
        
         Task {
             try? await queryClient.addObserver(self, for: queryKey)
             await execute()
         }
     }
    
     deinit {
         Task.detached { [queryClient, queryKey, observerId] in
             await queryClient.removeObserverById(observerId, for: queryKey)
         }
     }
    
     nonisolated func onQueryInvalidated(key: QueryKey) {
         Task { @MainActor [weak self] in
             if case .loading = self?.state { return }
             await self?.execute()
         }
     }
    
     func execute() async {
         if case .loading = state {
             return
         }
        
         state = .loading
        
         if let cached: T = await queryClient.getCachedValue(forKey: queryKey) {
             state = .success(cached)
             return
         }
        
         do {
             let result = try await queryFn()
             await queryClient.setCachedValue(result, forKey: queryKey)
             state = .success(result)
         } catch {
             state = .error(error)
         }
     }
    
     func invalidate() async {
         if case .loading = state {
             return
         }
        
         await queryClient.invalidateQueries(matching: queryKey)
     }
 }

 @MainActor
 class PaginatedQuery<T>: ObservableObject {
     @Published private(set) var state: LoadingState<QueryPage<T>> = .idle
     private let queryClient: QueryClient
     private let queryKey: QueryKey
     private let queryFn: (PaginationParams) async throws -> QueryPage<T>
    
     init(
         queryKey: QueryKey,
         queryFn: @escaping (PaginationParams) async throws -> QueryPage<T>,
         queryClient: QueryClient = .shared
     ) {
         self.queryKey = queryKey
         self.queryFn = queryFn
         self.queryClient = queryClient
     }
    
     func fetchPage(page: Int, pageSize: Int) async {
         let paginationParams = PaginationParams(page: page, pageSize: pageSize)
         let pageQueryKey = QueryKey(queryKey.components + [page])
        
         state = .loading
        
         if let cached: QueryPage<T> = await queryClient.getCachedValue(forKey: pageQueryKey) {
             state = .success(cached)
             return
         }
        
         do {
             let result = try await queryFn(paginationParams)
             await queryClient.setCachedValue(result, forKey: pageQueryKey)
             state = .success(result)
         } catch {
             state = .error(error)
         }
     }
 }

 @MainActor
 class Mutation<Input, Output> {
     private let queryClient: QueryClient
     private let mutationFn: (Input) async throws -> Output
     private let invalidateKeys: [QueryKey]
    
     @Published private(set) var state: LoadingState<Output> = .idle
    
     init(
         queryClient: QueryClient = .shared,
         invalidateKeys: [QueryKey] = [],
         mutationFn: @escaping (Input) async throws -> Output
     ) {
         self.queryClient = queryClient
         self.invalidateKeys = invalidateKeys
         self.mutationFn = mutationFn
     }
    
     func execute(_ input: Input) async {
         state = .loading
        
         do {
             let result = try await mutationFn(input)
             state = .success(result)
            
             // Invalidate related queries
             for key in invalidateKeys {
                 await queryClient.invalidateQueries(matching: key)
             }
         } catch {
             state = .error(error)
         }
     }
 }*/

// MARK: Examples

// Example of query definitions in a separate file (Queries.swift)
/* enum TodoQueries {
     static func getTodo(id: Int) -> Query<Todo> {
         Query(
             queryKey: QueryKey("todo", id),
             queryFn: {
                 let url = URL(string: "https://api.example.com/todos/\(id)")!
                 let (data, _) = try await URLSession.shared.data(from: url)
                 return try JSONDecoder().decode(Todo.self, from: data)
             }
         )
     }
    
     static func getTodos() -> PaginatedQuery<Todo> {
         PaginatedQuery(
             queryKey: QueryKey("todos"),
             queryFn: { params in
                 let url = URL(string: "https://api.example.com/todos?page=\(params.page)&pageSize=\(params.pageSize)")!
                 let (data, _) = try await URLSession.shared.data(from: url)
                 return try JSONDecoder().decode(QueryPage<Todo>.self, from: data)
             }
         )
     }
 }

 // Example usage in views
 struct TodoDetailView: View {
     @StateObject private var todoQuery: Query<Todo>
     let todoId: Int
    
     init(todoId: Int) {
         _todoQuery = StateObject(wrappedValue: TodoQueries.getTodo(id: todoId))
     }
    
     var body: some View {
         content
             .task {
                 await todoQuery.execute()
             }
     }
    
     private var content: some View {
         switch todoQuery.state {
         case .idle, .loading:
             return AnyView(ProgressView())
         case .success(let todo):
             return AnyView(
                 VStack {
                     Text(todo.title)
                     Button("Invalidate") {
                         Task {
                             await todoQuery.invalidate()
                             await todoQuery.execute()
                         }
                     }
                 }
             )
         case .error(let error):
             return AnyView(Text(error.localizedDescription))
         }
     }
 }

 struct TodoListView: View {
     @StateObject private var todosQuery = TodoQueries.getTodos()
     @State private var currentPage = 1
     private let pageSize = 10
    
     var body: some View {
         switch todosQuery.state {
         case .idle, .loading:
             ProgressView()
         case .success(let page):
             List {
                 ForEach(page.items, id: \.id) { todo in
                     Text(todo.title)
                 }
                
                 if page.hasNextPage {
                     ProgressView()
                         .onAppear {
                             loadNextPage()
                         }
                 }
             }
         case .error(let error):
             Text(error.localizedDescription)
         }
         .task {
             await todosQuery.fetchPage(page: currentPage, pageSize: pageSize)
         }
     }
    
     private func loadNextPage() {
         guard case .success(let page) = todosQuery.state,
               page.hasNextPage else {
             return
         }
        
         Task {
             currentPage += 1
             await todosQuery.fetchPage(page: currentPage, pageSize: pageSize)
         }
     }
 }
 */
