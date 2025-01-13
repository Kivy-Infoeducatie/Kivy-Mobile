//
//  AddWidgetSheet.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 18.12.2024.
//

import SwiftUI

struct AddWidgetSheet: View {
    let widgetType: WidgetType
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var scrollPosition: ScrollPosition = .init(
        idType: WidgetSize.self
    )
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                VStack {
                    VStack(spacing: 8) {
                        Text(widgetType.name)
                            .font(.title.bold())
                        Text(widgetType.description)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    Spacer()
                    
                    VStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(widgetType.supportedSizes, id: \.self) { size in
                                    VStack {
                                        WidgetView(
                                            widget: .init(
                                                type: widgetType,
                                                size: size,
                                                order: 0
                                            ),
                                            geometry: geo
                                        )
                                    }
                                    .frame(width: geo.size.width)
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.paging)
                        .scrollPosition($scrollPosition)
                        .onAppear {
                            scrollPosition
                                .scrollTo(id: widgetType.supportedSizes.first)
                        }
                    }
                    
                    HStack(spacing: 6) {
                        ForEach(widgetType.supportedSizes, id: \.self) { size in
                            Circle()
                                .frame(width: 7)
                                .foregroundStyle(
                                    size == scrollPosition.viewID(type: WidgetSize.self)
                                        ? .accent.opacity(1)
                                        : .accent.opacity(0.2)
                                )
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        modelContext.insert(
                            Widget(
                                type: widgetType,
                                size: scrollPosition.viewID(type: WidgetSize.self) ?? .small,
                                order: 0
                            )
                        )
                        dismiss()
                    }
                    label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Widget")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.accent)
                        .foregroundStyle(.background)
                        .clipShape(.rect(cornerRadius: 20))
                        .padding()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    CloseButton {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddWidgetSheet(widgetType: .goals)
}
