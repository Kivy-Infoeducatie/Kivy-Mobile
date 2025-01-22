//
//  AccountScreen.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 22.01.2025.
//

import SwiftUI

struct AccountScreen: View {
    @Environment(\.dismiss) var dismiss

    @StateObject private var account = AccountQueries.getAccount()
    @State private var showEditProfile = false

    var body: some View {
        NavigationStack {
            Group {
                switch account.state {
                case .success(let account):
                    List {
                        Section {
                            VStack(alignment: .center) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundStyle(.secondary)
                                Text("\(account.firstName) \(account.lastName)")
                                    .font(.title2)
                                    .bold()
                                Text("\(account.email)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        Section {
                            Button {
                                showEditProfile.toggle()
                            } label: {
                                HStack {
                                    Label("Edit profile", systemImage: "person")
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .opacity(0.25)
                                        .font(.system(size: 13))
                                        .bold()
                                }
                            }
                            NavigationLink {
                                Text("Settings")
                            } label: {
                                Label("Settings", systemImage: "gear")
                            }
                        }

                        Button("Log out", role: .destructive) {
                            Auth.shared.clearToken()
                        }
                    }
                    .scrollContentBackground(.hidden)
                case .error(let error):
                    ErrorView(error: error.localizedDescription) {
                        await account.invalidate()
                    }
                default:
                    ProgressView()
                }
            }
            .navigationTitle("Account")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileScreen(account: account.state.value!)
                    .presentationBackground(.ultraThinMaterial)
            }
        }
    }
}

#Preview {
    AccountScreen()
}

struct EditProfileScreen: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentToast) var presentToast

    @StateObject private var updateAccount = AccountQueries.updateAccount()
    @State private var updatedAccount: UpdateAccountDTO
    
    init(account: Account) {
        self._updatedAccount = State(initialValue: .init(
            email: account.email,
            firstName: account.firstName,
            lastName: account.lastName,
            username: account.username
        ))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Username") {
                    TextField("Username", text: $updatedAccount.username)
                        .textContentType(.username)
                }
                Section("First Name") {
                    TextField("First Name", text: $updatedAccount.firstName)
                        .textContentType(.givenName)
                }
                Section("Last Name") {
                    TextField("Last Name", text: $updatedAccount.lastName)
                        .textContentType(.familyName)
                }
                Section("Email") {
                    TextField("Email", text: $updatedAccount.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                }
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.immediately)
            .listSectionSpacing(4)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        updateAccount.execute(
                            updatedAccount,
                            presenting: presentToast,
                            successMessage: "Profile updated successfully",
                            errorTransform: { error in
                                "Failed to update profile"
                            },
                            onSuccess: { _ in
                                dismiss()
                            }
                        )
                    }
                }
            }
        }
    }
}
