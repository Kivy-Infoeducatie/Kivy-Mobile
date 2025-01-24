//
//  EditProfileScreen.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 24.01.2025.
//

import SwiftUI

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
