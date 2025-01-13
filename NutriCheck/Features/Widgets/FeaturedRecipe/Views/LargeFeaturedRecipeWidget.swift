//
//  LargeFeaturedRecipeWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 18.12.2024.
//

import SwiftUI
import CachedAsyncImage

struct LargeFeaturedRecipeWidget: View {
    let widget: Widget

    var body: some View {
        ZStack(alignment: .bottomLeading) {
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
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                case .failure:
                    Image(systemName: "photo")
                default:
                    Image(systemName: "photo")
                }
            }

            VariableBlurView(direction: .blurredBottomClearTop)
                .frame(height: 100)
            VStack(alignment: .leading) {
                HStack(spacing: 4) {
                    Image(systemName: widget.type.icon)
                    Text(widget.type.title)
                        .font(.system(size: 14, weight: .semibold))
                }
                .opacity(0.9)
                Text("Sarmale de post")
                    .font(.title3.bold())
                Text("by Jamila Cuisine")
                    .font(.callout.bold())
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}
