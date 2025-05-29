//
//  NavigationWrapper.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 26.01.2025.
//

import SwiftUI
import SwiftData
import Toasts

struct NavigationWrapper<Content: View>: View {
    let title: String
    let content: Content
    
    @State private var showAccount = false
    @State private var showSearch = false
    @State private var showAdd = false
    @State private var showCreateRecipe = false
    @State private var showLogFood = false
    @State private var showLogWater = false

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            content
                .overlay(alignment: .top) {
                    GeometryReader { geo in
                        ZStack(alignment: .topLeading) {
                            VariableBlurView(
                                maxBlurRadius: 10,
                                direction: .blurredTopClearBottom
                            )
                            .frame(height: geo.safeAreaInsets.top + 70)
                            HStack {
                                Text(title)
                                    .font(
                                        .title2
                                            .weight(.bold)
                                            .width(.init(0.16))
                                    )
                                
                                Spacer()
                                
                                Button {
                                    showAdd.toggle()
                                } label: {
                                    Image(systemName: "plus")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                        .bold()
                                        .padding(8)
                                        .opacity(0.9)
                                        .background {
                                            Circle()
                                                .fill(.thinMaterial)
                                        }
                                }
                                
                                Button {
                                    showSearch.toggle()
                                } label: {
                                    Image(systemName: "magnifyingglass")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                        .bold()
                                        .padding(8)
                                        .opacity(0.9)
                                        .background {
                                            Circle()
                                                .fill(.thinMaterial)
                                        }
                                }
                                
                                Button {
                                    showAccount.toggle()
                                } label: {
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                        .padding(8)
                                        .opacity(0.9)
                                        .background {
                                            Circle()
                                                .fill(.thinMaterial)
                                        }
                                }
                            }
                            .padding(.bottom, 12)
                            .padding(.horizontal)
                            .padding(.top, geo.safeAreaInsets.top + 12)
                        }
                        .ignoresSafeArea()
                    }
                }
        }
        .sheet(isPresented: $showAccount) {
            AccountScreen()
                .presentationBackground(.thinMaterial)
        }
        .sheet(isPresented: $showSearch) {
            SearchScreen()
                .presentationBackground(.thinMaterial)
        }
        .confirmationDialog("Create", isPresented: $showAdd) {
            Button("Create Recipe") {
                showCreateRecipe.toggle()
            }
            Button("Log Food") {
                showLogFood.toggle()
            }
            Button("Log Water") {
                showLogWater.toggle()
            }
        }
        .sheet(isPresented: $showCreateRecipe) {
            CreateRecipeScreen()
                .presentationBackground(.thinMaterial)
        }
        .sheet(isPresented: $showLogFood) {
            LogCalories()
                .presentationBackground(.thinMaterial)
        }
        .sheet(isPresented: $showLogWater) {
            LogWaterView()
                .presentationBackground(.thinMaterial)
        }
    }
}

struct LogCalories: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentToast) private var presentToast
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var calorieViewModel: CalorieIntakeViewModel
    @StateObject private var log = GoalsQueries.logCalories()
    
    @State private var calories: Int = 300
    @State private var notes: String = ""
    @State private var useApiLogging: Bool = true // Option to also log to API
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Quick calorie buttons
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Add")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach([200, 300, 400, 500, 600, 800], id: \.self) { quickCalories in
                            Button {
                                calories = quickCalories
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "flame.fill")
                                        .font(.title2)
                                    Text("\(quickCalories)")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(calories == quickCalories ? .white : .orange)
                                .frame(height: 60)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(calories == quickCalories ? .orange : .orange.opacity(0.1))
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Custom amount and notes
                Form {
                    Section("Calories") {
                        Picker("Amount", selection: $calories) {
                            ForEach(Array(stride(from: 50, to: 3000, by: 25)), id: \.self) { value in
                                Text("\(value) kcal").tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    
                    Section("Notes (Optional)") {
                        TextField("What did you eat?", text: $notes, axis: .vertical)
                            .lineLimit(2...4)
                    }
                }
            }
            .navigationTitle("Log Calories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        logCalories()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func logCalories() {
        // Save to local SwiftData
        let calorieIntake = CalorieIntake(
            amount: Double(calories),
            source: notes.isEmpty ? "Manual entry" : notes,
            sourceType: .manual,
            notes: notes.isEmpty ? nil : notes
        )
        modelContext.insert(calorieIntake)
        
        do {
            try modelContext.save()
            
            // Also log to API if enabled
            if useApiLogging {
                log.execute(
                    Double(calories),
                    presenting: presentToast,
                    successMessage: "\(calories) calories logged"
                )
            } else {
                let toast = ToastValue(
                    icon: Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.orange),
                    message: "\(calories) calories logged"
                )
                presentToast(toast)
            }
            
            dismiss()
        } catch {
            print("Failed to save calorie intake: \(error)")
            
            let toast = ToastValue(
                icon: Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red),
                message: "Failed to log calories"
            )
            presentToast(toast)
        }
    }
}
