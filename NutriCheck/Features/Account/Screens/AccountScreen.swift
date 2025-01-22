//
//  AccountScreen.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 22.01.2025.
//

import SwiftUI

struct AccountScreen: View {
    @StateObject private var account = AccountQueries.getAccount()

    var body: some View {
        NavigationStack {
            switch account.state {
            case .success(let account):
                List {
                    Section {
                        VStack(alignment: .center) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                            Text("")
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    Section {
                        NavigationLink {
                            Text("Profile")
                        } label: {
                            Label("Profile", systemImage: "person")
                        }
                        NavigationLink {
                            Text("Settings")
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }

                    Button("Logout", role: .destructive) {
                        Auth.shared.clearToken()
                    }
                }
            case .loading:
                ProgressView()
            case .error(let error):
                VStack {
                    Text("Error")
                    Text(error.localizedDescription)
                }
                .foregroundStyle(.red)
            default:
                EmptyView()
            }
        }
    }
}

#Preview {
    AccountScreen()
}
