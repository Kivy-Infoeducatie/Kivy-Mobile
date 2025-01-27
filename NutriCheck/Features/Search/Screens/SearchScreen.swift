//
//  SearchScreen.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 25.01.2025.
//

import SwiftUI

struct SearchScreen: View {
    @Environment(\.dismiss) var dismiss

    @State private var query = ""
    @FocusState private var focusedField: FocusedField?
    @EnvironmentObject private var recents: RecentSearchesViewModel

    enum FocusedField {
        case query
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                VStack(alignment: .leading) {
                    ForEach(recents.searches.reversed(), id: \.self) { recent in
                        RecentSearchChip(recent: recent)
                    }
                }
                
                
                HStack(spacing: 8) {
                    TextField("Search", text: $query)
                        .focused($focusedField, equals: .query)
                        .frame(height: 48)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.regularMaterial)
                        )
                        .frame(maxWidth: .infinity)
                        .shadow(color: Color.black.opacity(0.15), radius: 8)

                    NavigationLink {
                        SearchResultsScreen(query: query)
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .padding(16)
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.regularMaterial)
                            }
                    }
                    .shadow(color: Color.black.opacity(0.15), radius: 8)
                }
            }
            .padding()
            .navigationTitle("Search")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    CloseButton {
                        dismiss()
                    }
                }
            }
            .onAppear {
                focusedField = .query
            }
        }
    }
}

#Preview {
    SearchScreen()
}
