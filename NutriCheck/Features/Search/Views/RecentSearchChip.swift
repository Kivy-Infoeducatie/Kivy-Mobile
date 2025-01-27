//
//  RecentSearchChip.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 26.01.2025.
//

import SwiftUI

struct RecentSearchChip: View {
    let recent: String
    
    var body: some View {
        NavigationLink {
            SearchResultsScreen(query: recent)
        } label: {
            HStack {
                Image(systemName: "clock")
                    .opacity(0.8)
                Text(recent)
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.thinMaterial)
            }
        }
    }
}
