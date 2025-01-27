//
//  AddWidgetSheet.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 16.12.2024.
//

import SwiftData
import SwiftUI

struct EditWidgetsSheet: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Query(sort: \Widget.order) private var widgets: [Widget]

    @State private var showAddWidget = false
    @State private var widgetType: WidgetType = .goals

    var body: some View {
        NavigationStack {
            List {
                Section("Edit widgets") {
                    ForEach(widgets) { widget in
                        HStack {
                            Image(systemName: widget.type.icon)
                                .foregroundStyle(widget.type.color)
                            Text("\(widget.type.name)")
                            Image(systemName: widget.size.rawValue.prefix(1).lowercased() + ".circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onMove { from, to in
                        do {
                            var widgetsCopy = widgets
                            widgetsCopy.move(fromOffsets: from, toOffset: to)
                            reorder(widgets: widgetsCopy)
                            try modelContext.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            modelContext.delete(widgets[index])
                        }
                        reorder(widgets: widgets)
                    }
                    
                    if widgets.isEmpty {
                        VStack {
                            Image(systemName: "plus.circle")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(.secondary)
                            Text("No widgets added yet")
                                .bold()
                            Text("Add a widget to get started")
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .headerProminence(.increased)

                Section("Add a widget") {
                    ForEach(WidgetType.allCases, id: \WidgetType.id) { type in
                        if !type.hidden {
                            Button {
                                widgetType = type
                                showAddWidget = true
                            } label: {
                                HStack {
                                    Image(systemName: type.icon)
                                        .foregroundStyle(type.color)
                                    Text("\(type.name)")
                                    
                                    Spacer()
                                    
                                    Image(systemName: "plus.circle")
                                }
                            }
                        }
                    }
                }
                .headerProminence(.increased)
            }
            .scrollContentBackground(.hidden)
            .environment(\.editMode, .constant(.active))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        withAnimation {
                            dismiss()
                        }
                    } label: {
                        Text("Done")
                    }
                }
            }
            .navigationTitle("Widgets")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddWidget, onDismiss: {
                reorder(widgets: widgets)
            }) {
                AddWidgetSheet(widgetType: widgetType)
                    .presentationDetents([.large])
                    .presentationBackground(.thinMaterial)
            }
        }
    }

    private func reorder(widgets: [Widget]) {
        for (index, _) in widgets.enumerated() {
            widgets[index].order = index
        }
    }
}


 #Preview {
    EditWidgetsSheet()
 }
