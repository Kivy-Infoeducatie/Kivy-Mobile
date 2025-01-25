//
//  CustomTabBar.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 19.12.2024.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: TabModel
    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabModel.allCases, id: \.title) { tab in
                Button {
                    withAnimation(.snappy(duration: 0.25)) {
                        selectedTab = tab
                    }
                } label: {
                    HStack {
                        Image(systemName: tab.icon)
                            .font(.title3.bold())
                            .opacity(selectedTab == tab ? 0.9 : 0.8)
                            .padding(.vertical, 8)
                            .padding(.horizontal, selectedTab == tab ? 16 : 12)
                            .background {
                                if selectedTab == tab {
                                    Capsule()
                                        .fill(.thinMaterial)
                                        .matchedGeometryEffect(
                                            id: "tab",
                                            in: namespace
                                        )
                                }
                            }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .ignoresSafeArea()
        .padding(8)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
        }
        .sensoryFeedback(
            .impact(flexibility: .soft, intensity: 0.8),
            trigger: selectedTab
        )
    }
}

#Preview {
    ContentView()
}
