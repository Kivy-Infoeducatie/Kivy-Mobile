//
//  OngoingRecipeScreen.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 12.01.2025.
//

import CachedAsyncImage
import SwiftUI

struct OngoingRecipeScreen: View {
    @EnvironmentObject private var viewModel: OngoingRecipeViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @State private var showAllIngredients = false

    var body: some View {
        NavigationStack {
            ScrollView {
                if let recipe = viewModel.recipe {
//                if true {
//                    let recipe = recipes[0]
                    VStack(alignment: .leading) {
                        HStack(spacing: 20) {
                            CachedAsyncImage(url: URL(string: recipe.images[0])) { result in
                                switch result {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(
                                            width: 80,
                                            height: 80
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
                            .background {
                                CachedAsyncImage(url: URL(string: recipe.images[0])) { result in
                                    switch result {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(
                                                width: 110,
                                                height: 110
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
                                .blur(radius: 20)
                                .opacity(0.5)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(recipe.name)
                                    .font(.headline)
                                Text("by \(recipe.authorName)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.thinMaterial)
                        .clipShape(.rect(cornerRadius: 16))
                        
                        Text("Step \(viewModel.currentStepIndex + 1)")
                            .font(.title3.bold())
                            .padding(.top)
                        
                        VStack(alignment: .leading) {
                            Text("\(viewModel.currentStep ?? "")")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.thinMaterial)
                        .clipShape(.rect(cornerRadius: 16))
                        
                        HStack {
                            if viewModel.currentStepIndex > 0 {
                                Button {
                                    withAnimation {
                                        viewModel.previousStep()
                                    }
                                } label: {
                                    Image(systemName: "arrow.left")
                                        .font(.title2)
                                        .padding()
                                        .background(.thinMaterial)
                                        .clipShape(.circle)
                                }
                            }
                            
                            Spacer()
                            
                            if !viewModel.isLastStep {
                                Button {
                                    withAnimation {
                                        viewModel.nextStep()
                                    }
                                } label: {
                                    Image(systemName: "arrow.right")
                                        .font(.title2)
                                        .padding()
                                        .background(.thinMaterial)
                                        .clipShape(.circle)
                                }
                            }
                            
                            if viewModel.isLastStep {
                                Button {
                                    withAnimation {
                                        viewModel.endRecipe()
                                        dismiss()
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "checkmark")
                                            .font(.title2)
                                        Text("Finish")
                                    }
                                    .padding()
                                    .background(.thinMaterial)
                                    .clipShape(.capsule)
                                }
                            }
                        }
                        
                        Text("Ingredients")
                            .font(.title3.bold())
                            .padding(.top)
                        
                        VStack(alignment: .leading) {}
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(.rect(cornerRadius: 16))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                } else {
                    Text("No ongoing recipe")
                        .font(.title)
                        .foregroundColor(.secondary)
                        .padding(.top, 30)
                }
            }
            .navigationTitle("Ongoing Recipe")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButton {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAllIngredients.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "list.bullet")
                                .font(.caption)
                            Text("Ingredients")
                                .font(.subheadline)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(.thinMaterial)
                        .clipShape(.capsule)
                    }
                }
            }
            .sheet(isPresented: $showAllIngredients) {
                ScrollView {
                    if let recipe = viewModel.recipe {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("All Ingredients")
                                .font(.title3.bold())
                            ForEach(
                                Array(recipe.ingredients.enumerated()),
                                id: \.offset
                            ) { _, ingredient in
                                HStack(spacing: 2) {
                                    if let quantity = ingredient.quantity {
                                        Text("\(quantity) \(ingredient.unit ?? "")")
                                            .font(.body.bold())
                                            .padding(4)
                                            .padding(.horizontal, 5)
                                            .background(Color.blue.opacity(0.2))
                                            .clipShape(.rect(cornerRadius: 10))
                                            .foregroundStyle(.blue)
                                    }
                                    Text(" \(ingredient.name)")
                                        .font(.body)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding()
                    }
                }
                .presentationDetents([.height(300), .medium, .large])
                .presentationBackground(.thinMaterial)
                .presentationBackgroundInteraction(.enabled)
            }
        }
    }
}

#Preview {
    OngoingRecipeScreen()
        .environmentObject(OngoingRecipeViewModel())
}
