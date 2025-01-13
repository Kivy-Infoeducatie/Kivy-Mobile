//
//  LoginScreen.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 09.01.2025.
//

import SwiftUI
import Toasts
import Alamofire

struct LoginScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentToast) var presentToast

    @StateObject private var login = AuthMutations.login()
    @StateObject private var signUp = AuthMutations.signUp()

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var repeatPassword: String = ""

    @State private var isSignUp = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    VStack(spacing: 0) {
                        Image(.logo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                        Text("NutriCheck")
                            .font(.title.weight(.bold).width(.init(0.16)))
                            .opacity(0.6)
                    }
                    VStack {
                        VStack(spacing: 12) {
                            if isSignUp {
                                AuthTextField(
                                    text: $firstName,
                                    placeholder: "First Name",
                                    isSecure: false
                                )

                                AuthTextField(
                                    text: $lastName,
                                    placeholder: "Last Name",
                                    isSecure: false
                                )

                                AuthTextField(
                                    text: $username,
                                    placeholder: "Username",
                                    isSecure: false
                                )
                            }

                            AuthTextField(
                                text: $email,
                                placeholder: "Email",
                                isSecure: false,
                                validation: { $0.contains("@") }
                            )
                            AuthTextField(
                                text: $password,
                                placeholder: "Password",
                                isSecure: true
                            )

                            if isSignUp {
                                AuthTextField(
                                    text: $repeatPassword,
                                    placeholder: "Repeat Password",
                                    isSecure: true,
                                    validation: { $0 == password }
                                )
                            }
                        }
                        .background {
                            MeshGradient(width: 2, height: 2, points: [
                                [0, 0], [1, 0], [0, 1], [1, 1]
                            ], colors: [.purple, .blue, .red, .yellow])
                                .frame(height: 350)
                                .clipShape(.ellipse)
                                .blur(radius: 70)
                                .padding(-16)
                                .opacity(0.4)
                        }

                        Spacer(minLength: 20)

                        LargeButton(
                            title: isSignUp ? "Sign Up" : "Login",
                            background: Color.accentColor.opacity(0.5)
                        ) {
                            if isSignUp {
                                Task {
                                    await signUp.execute(
                                        SignUpDTO(
                                            firstName: firstName,
                                            lastName: lastName,
                                            username: username,
                                            email: email,
                                            password: password
                                        )
                                    )
                                }
                            } else {
                                Task {
                                    await login.execute(
                                        LoginDTO(
                                            email: email,
                                            password: password
                                        )
                                    )
                                }
                            }
                        }
                        Button("login") {
                            Auth.shared.setToken("test")
                        }

                        Spacer(minLength: 60)

                        Button {
                            withAnimation {
                                isSignUp.toggle()
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(
                                        isSignUp
                                            ? "Already have an account? Log in"
                                            : "Don't have an account? Sign up"
                                    )
                                    .bold()
                                    .multilineTextAlignment(.leading)
                                    .opacity(0.7)
                                }
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)

                                Spacer()

                                Image(systemName: "arrow.right")
                                    .bold()
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .foregroundStyle(.white)
                                    .background {
                                        Capsule()
                                            .fill(.thinMaterial)
                                            .environment(\.colorScheme, .dark)
                                    }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .background {
                                LighterMeshGradientView()
                                    .clipShape(.rect(cornerRadius: 20))
                                    .opacity(0.5)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .listSectionSpacing(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .background(Color(.lightGray).opacity(0.1))
        }
        .onAppear {
            _ = login.onError { error in
                let message: String
                if let error = error as? AFError {
                    switch error {
                    case .responseValidationFailed(reason: .unacceptableStatusCode(code: 401)):
                        message = "Invalid email or password"
                    default:
                        message = "Login failed"
                    }
                } else {
                    message = "Login failed"
                }

                print(error)
                let toast = ToastValue(
                    icon: Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red),
                    message: message
                )
                presentToast(toast)
            }

            _ = signUp.onError { error in
                print(error)
                let toast = ToastValue(
                    icon: Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red),
                    message: "Sign up failed"
                )
                presentToast(toast)
            }
            
            _ = signUp.onSuccess { _ in
                let toast = ToastValue(
                    icon: Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green),
                    message: "Sign up successful"
                )
                presentToast(toast)
            }
        }
    }
}

struct AuthTextField: View {
    @Binding var text: String
    let placeholder: String
    let isSecure: Bool
    let validation: (String) -> Bool
    let errorMessage: String

    init(
        text: Binding<String>,
        placeholder: String,
        isSecure: Bool,
        validation: @escaping (String) -> Bool = { $0.count > 0 },
        errorMessage: String? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.isSecure = isSecure
        self.validation = validation
        self.errorMessage = errorMessage ?? "\(placeholder) is invalid"
    }

    @State private var isValid = true

    var body: some View {
        VStack(alignment: .leading) {
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .textContentType(.password)
                        .textFieldStyle(.plain)
                        .frame(height: 48)
                        .padding(.horizontal)
                        .background(.thickMaterial.opacity(0.65))
                        .clipShape(.rect(cornerRadius: 16))
                } else {
                    TextField(placeholder, text: $text)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(.plain)
                        .frame(height: 48)
                        .padding(.horizontal)
                        .background(.thickMaterial.opacity(0.65))
                        .clipShape(.rect(cornerRadius: 16))
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isValid ? Color.clear : Color.red.opacity(0.6),
                        lineWidth: 1
                    )
            }

            if !isValid {
                Text("\(placeholder) is invalid")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .onChange(of: text) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isValid = validation(text)
            }
        }
    }
}

#Preview {
    LoginScreen()
}
