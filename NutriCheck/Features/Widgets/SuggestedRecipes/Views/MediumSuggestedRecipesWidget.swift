//
//  MediumSuggestedRecipesWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 19.12.2024.
//

import SwiftUI
import CachedAsyncImage

struct MediumSuggestedRecipesWidget: View {
    var body: some View {
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
                        .frame(width: 100, height: 100)
                        .clipShape(.rect(cornerRadius: 16))
                case .failure:
                    Image(systemName: "photo")
                default:
                    Image(systemName: "photo")
                }
            }
            VStack(alignment: .leading) {
                Text("Sarmale de post")
                    .font(.headline.bold())
                Text("by Jamila Cuisine")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 10)
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
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    MediumSuggestedRecipesWidget()
}
