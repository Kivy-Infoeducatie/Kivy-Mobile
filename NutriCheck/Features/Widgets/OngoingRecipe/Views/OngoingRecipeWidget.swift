//
//  OngoingRecipeWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 12.01.2025.
//

import CachedAsyncImage
import SwiftUI

struct OngoingRecipeWidget: View {
    let widget: Widget

    @EnvironmentObject private var viewModel: OngoingRecipeViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if let recipe = viewModel.recipe {
            WidgetWrapper(widget: widget, showTitle: widget.size != .small) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 20) {
                        CachedAsyncImage(url: URL(string: recipe.images[0])) { result in
                            switch result {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(
                                        width: 60,
                                        height: 60
                                    )
                                    .clipped()
                            case .empty:
                                ProgressView()
                            case .failure:
                                ProgressView()
                            default:
                                ProgressView()
                            }
                        }
                        .clipShape(.rect(cornerRadius: 16))

                        VStack(alignment: .leading) {
                            Text(recipe.name)
                                .font(.headline)
                            Text("by \(recipe.authorName)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack {
                        HStack(spacing: 16) {
                            ActivityRingView(
                                progress: viewModel.progress,
                                mainColor: colorScheme == .dark ? .white : .black,
                                lineWidth: 8
                            )
                            .frame(width: 20, height: 20)

                            Text("Step \(viewModel.currentStepIndex + 1) of \(recipe.steps.count)")
                                .font(.headline.bold())
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Button {
                            if viewModel.isLastStep {
                                withAnimation {
                                    viewModel.endRecipe()
                                }
                            } else {
                                withAnimation {
                                    viewModel.nextStep()
                                }
                            }
                        } label: {
                            HStack {
                                Text(viewModel.isLastStep ? "Finish" : "Next step")
                                Image(
                                    systemName: viewModel.isLastStep ? "checkmark" : "arrow.right"
                                )
                                    .font(.callout)
                                    .foregroundColor(.accentColor)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            .background(.thinMaterial)
                            .clipShape(.capsule)
                        }
                    }

                    Text(viewModel.currentStep ?? "")
                        .font(.callout)
                }
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    OngoingRecipeWidget(widget: .init(type: .ongoingRecipe, size: .large, order: 0))
        .environmentObject(OngoingRecipeViewModel())
}
