//
//  KeyboardManager.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 19.12.2024.
//

import SwiftUI
import Combine

class KeyboardManager: ObservableObject {
    @Published var isKeyboardVisible = false
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    init() {
        let keyboardWillShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { _ in true }
        
        let keyboardWillHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in false }
        
        Publishers.Merge(keyboardWillShow, keyboardWillHide)
            .assign(to: \.isKeyboardVisible, on: self)
            .store(in: &cancellableSet)
    }
}
