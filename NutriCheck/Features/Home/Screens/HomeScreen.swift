//
//  HomeScreen.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 15.12.2024.
//

import Alamofire
import SwiftData
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct HomeScreen: View {
    @Query(sort: \Widget.order) private var widgets: [Widget]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme

    @State private var currentDetent: PresentationDetent = .height(250)

    @State private var isEditMode = false

    var body: some View {
        NavigationStack {
            ZStack {
                if colorScheme == .dark {
                    CustomMeshGradientView()
                        .ignoresSafeArea()
                } else {
                    LightMeshGradientView()
                        .ignoresSafeArea()
                }
                GeometryReader { geo in
                    ScrollView {
                        WrapLayout(horizontalSpacing: 12, verticalSpacing: 12) {
                            NavigationLink(destination: SwiftQueryView()) {
                                Text("go")
                            }
                            Button("invalidate") {
                                Task {
                                    await QueryClient.shared
                                        .invalidateQueries(matching: .init("todo"))
                                }
                            }
                            Button("logout") {
                                Auth.shared.clearToken()
                            }
                            
                            WidgetView(
                                widget: .init(
                                    type: .ongoingRecipe,
                                    size: .large,
                                    order: 0
                                ),
                                geometry: geo
                            )
                            ForEach(
                                widgets
                            ) { widget in
                                WidgetView(
                                    widget: widget,
                                    geometry: geo
                                )
                                .opacity(isEditMode ? 0.3 : 1)
                                .overlay(
                                    isEditMode ? EditWidgetOverlay(widget: widget) : nil
                                )
                            }
                            VStack(alignment: .center) {
                                Button {
                                    withAnimation {
                                        isEditMode.toggle()
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text("Edit")
                                    }
                                }
                                .font(.callout)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background {
                                    Capsule()
                                        .fill(.thinMaterial)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 70)
                        .padding(.horizontal)
                        .padding(.bottom, isEditMode ? 300 : 80)
                    }
                    .sheet(isPresented: $isEditMode, onDismiss: {
                        currentDetent = .height(250)
                    }) {
                        EditWidgetsSheet()
                            .presentationDetents(
                                [.height(100), .height(250), .medium, .large],
                                selection: $currentDetent
                            )
                            .presentationBackgroundInteraction(.enabled)
                            .presentationBackground(.thinMaterial)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeScreen()
        .environmentObject(OngoingRecipeViewModel())
}

@MainActor
enum Queries {
    static func getTodo(id: Int) -> Query<String> {
        Query(
            queryKey: QueryKey("todo", id),
            queryFn: {
                try await Task.sleep(for: .seconds(3))
                return "todo \(id)"
            }
        )
    }
}

struct SwiftQueryView: View {
    @StateObject private var query: Query<String> = Queries.getTodo(id: 1)

    var body: some View {
        VStack {
            Group {
                switch query.state {
                case .idle:
                    Text("idle")
                case .loading:
                    Text("loading")
                case .success(let t):
                    Text(t)
                case .error(let error):
                    Text(error.localizedDescription)
                }
            }
            Button("invalidate") {
                Task {
                    await query.invalidate()
                }
            }
        }
    }
}
