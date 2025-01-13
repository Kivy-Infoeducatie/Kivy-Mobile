//
//  ShoppingListScreen.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 12.01.2025.
//

import SwiftData
import SwiftUI

struct ShoppingListScreen: View {
    @Environment(\.dismiss) var dismiss
    @Query private var shoppingListItems: [ShoppingListItem]
    
    @State private var isAddingItem = false

    var body: some View {
        NavigationStack {
            List {
                if shoppingListItems.isEmpty {
                    VStack {
                        Image(systemName: "cart")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("Your shopping list is empty")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                ForEach(shoppingListItems) { item in
                    ShoppingListItemRow(item: item)
                }
            }
            .navigationTitle("Shopping List")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAddingItem = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    CloseButton {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingItem) {
            AddShoppingListItemScreen()
        }
    }
}

#Preview {
    ShoppingListScreen()
}

struct ShoppingListItemRow: View {
    @Environment(\.modelContext) var modelContext
    
    let item: ShoppingListItem
    @State private var isChecked = false
    @State private var deletionTimer: Timer?
    
    private var quantityText: String {
        if item.unit == "pcs" {
            return String(item.quantity)
        } else {
            return String(format: "%.2f", item.quantity)
        }
    }
    
    var body: some View {
        HStack {
            Button {
                if isChecked {
                    cancelDeletion()
                } else {
                    withAnimation {
                        isChecked = true
                    }
                    startDeletionTimer()
                }
            } label: {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isChecked ? .green : .accentColor)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(item.name)
                .strikethrough(isChecked)
                .foregroundColor(isChecked ? .gray : .primary)
            
            Spacer()
            Text("\(quantityText) \(item.unit)")
                .foregroundColor(isChecked ? .gray : .primary)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                deleteItem()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .onDisappear {
            cancelDeletion()
        }
    }
    
    private func startDeletionTimer() {
        deletionTimer?.invalidate()
        deletionTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            deleteItem()
        }
    }
    
    private func cancelDeletion() {
        deletionTimer?.invalidate()
        deletionTimer = nil
        withAnimation {
            isChecked = false
        }
    }
    
    private func deleteItem() {
        deletionTimer?.invalidate()
        deletionTimer = nil
        modelContext.delete(item)
    }
}
struct AddShoppingListItemScreen: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State private var name = ""
    @State private var quantity = "1"
    @State private var unit = "pcs"
    
    @State private var unitOptions = ["kg", "g", "l", "ml", "pcs", "tbsp", "tsp", "cup"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.decimalPad)
                    Picker("Unit", selection: $unit) {
                        ForEach(unitOptions, id: \.self) { unit in
                            Text(unit)
                        }
                    }
                }
            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let item = ShoppingListItem(
                            name: name,
                            quantity: quantity,
                            unit: unit
                        )
                        
                        modelContext.insert(item)
                        dismiss()
                    }
                }
            }
        }
    }
}
