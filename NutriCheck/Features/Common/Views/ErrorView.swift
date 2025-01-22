//
//  ErrorView.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 22.01.2025.
//

import SwiftUI

struct ErrorView: View {
    let error: String
    let retry: () async -> Void

    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            Text("Error")
            Text(error)
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task {
                    await retry()
                }
            }
            .foregroundStyle(.accent)
            .padding()
        }
        .foregroundStyle(.red)
    }
}

#Preview {
    ErrorView(error: "An error occurred", retry: {})
}
