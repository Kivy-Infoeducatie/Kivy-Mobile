//
//  SavedRecipesViewModel.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 25.01.2025.
//

import Foundation

class RecentSearchesViewModel: ObservableObject {
    static let shared = RecentSearchesViewModel()
    
    // MARK: - Published Properties
    @Published private(set) var searches: [String] = []
    
    // MARK: - Storage Keys
    private let searchesKey = "recent_searches"
    private let storage = UserDefaults.standard
    
    init() {
        loadState()
    }
    
    // MARK: - Public Methods
    func saveSearch(_ search: String) {
        guard !searches.contains(search) else { return }
        searches.insert(search, at: 0)
        if searches.count > 3 {
            searches.removeLast()
        }
        saveState()
    }
    
    // MARK: - Private Methods
    private func loadState() {
        if let data = storage.data(forKey: searchesKey),
           let searches = try? JSONDecoder().decode([String].self, from: data) {
            self.searches = searches
        }
    }
    
    private func saveState() {
        if let data = try? JSONEncoder().encode(searches) {
            storage.set(data, forKey: searchesKey)
        }
    }
}
