//
//  LargeSuggestedRecipesWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 19.12.2024.
//

import SwiftUI
import CachedAsyncImage

struct LargeSuggestedRecipesWidget: View {
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<3) { _ in
                HStack(spacing: 20) {
                    CachedAsyncImage(
                        url: URL(
                            string: "https://retete-thermomix.ro/wp-content/uploads/2021/12/Sarmale.webp"
                        )
                    ) { result in
                        switch result {
                        case .empty:
                            Image(systemName: "photo")
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(.rect(cornerRadius: 12))
                        case .failure:
                            Image(systemName: "photo")
                        default:
                            Image(systemName: "photo")
                        }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sarmale de post")
                            .font(.headline.bold())
                        Text("by Jamila Cuisine")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        HStack {
                            Text("300kcal")
                                .font(.subheadline)
                            Divider()
                                .frame(height: 12)
                            Text("Easy")
                                .font(.subheadline)
                            Divider()
                                .frame(height: 12)
                            Text("30m")
                                .font(.subheadline)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    LargeSuggestedRecipesWidget()
}
