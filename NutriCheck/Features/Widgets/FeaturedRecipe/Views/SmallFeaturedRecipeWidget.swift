//
//  SmallFeaturedRecipeWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 18.12.2024.
//

import SwiftUI
import CachedAsyncImage

struct SmallFeaturedRecipeWidget: View {
    let widget: Widget
    let height: CGFloat?

    init(widget: Widget, height: CGFloat? = nil) {
        self.widget = widget
        self.height = height
    }

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
                        .frame(height: height)
                case .failure:
                    Image(systemName: "photo")
                default:
                    Image(systemName: "photo")
                }
            }

            VariableBlurView(direction: .blurredBottomClearTop)
                .frame(height: 80)
            VStack(alignment: .leading) {
                HStack(spacing: 4) {
                    Image(systemName: widget.type.icon)
                    Text(widget.type.title)
                        .font(.system(size: 14, weight: .semibold))
                }
                .opacity(0.9)
                Text("Sarmale de post")
                    .font(.callout.bold())
                Text("by Jamila Cuisine")
                    .font(.caption.bold())
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
    }
}
