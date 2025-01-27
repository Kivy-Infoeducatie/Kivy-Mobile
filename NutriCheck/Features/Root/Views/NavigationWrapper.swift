//
//  NavigationWrapper.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 26.01.2025.
//

import SwiftUI

struct NavigationWrapper<Content: View>: View {
    let title: String
    let content: Content
    
    @State private var showAccount = false
    @State private var showSearch = false

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
    }
}
