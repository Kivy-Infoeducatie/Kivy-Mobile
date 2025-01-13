//
//  EditWidgetOverlay.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 17.12.2024.
//

import SwiftUI

struct EditWidgetOverlay: View {
    @State var widget: Widget
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation {
                        modelContext.delete(widget)
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.red)
                }
                Spacer()
                Menu {
                    Picker("Size", selection: $widget.size) {
                        ForEach(widget.type.supportedSizes, id: \.self) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .imageScale(.medium)
                }
            }
            .padding(12)
            Spacer()
        }
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Color(.secondarySystemBackground).opacity(0.3))
        }
    }
}
