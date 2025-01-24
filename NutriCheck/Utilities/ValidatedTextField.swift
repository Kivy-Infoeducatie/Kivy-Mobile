//
//  ValidationRule.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 24.01.2025.
//

import SwiftUI




// MARK: - Validation Rules
struct ValidationRule<T> {
    let validate: (T) -> Bool
    let message: String
    
    static func custom(_ validator: @escaping (T) -> Bool, message: String) -> ValidationRule<T> {
        ValidationRule(validate: validator, message: message)
    }
}

// MARK: - Number Validation Rules
extension ValidationRule where T == Double {
    static func min(_ value: Double, message: String? = nil) -> ValidationRule<Double> {
        ValidationRule(
            validate: { $0 >= value },
            message: message ?? "Value must be at least \(value)"
        )
    }
    
    static func max(_ value: Double, message: String? = nil) -> ValidationRule<Double> {
        ValidationRule(
            validate: { $0 <= value },
            message: message ?? "Value must be at most \(value)"
        )
    }
    
    static func range(_ range: ClosedRange<Double>, message: String? = nil) -> ValidationRule<Double> {
        ValidationRule(
            validate: { range.contains($0) },
            message: message ?? "Value must be between \(range.lowerBound) and \(range.upperBound)"
        )
    }
    
    static func nonZero(message: String? = nil) -> ValidationRule<Double> {
        ValidationRule(
            validate: { $0 != 0 },
            message: message ?? "Value cannot be zero"
        )
    }
}

extension ValidationRule where T == Int {
    static func min(_ value: Int, message: String? = nil) -> ValidationRule<Int> {
        ValidationRule(
            validate: { $0 >= value },
            message: message ?? "Value must be at least \(value)"
        )
    }
    
    static func max(_ value: Int, message: String? = nil) -> ValidationRule<Int> {
        ValidationRule(
            validate: { $0 <= value },
            message: message ?? "Value must be at most \(value)"
        )
    }
    
    static func range(_ range: ClosedRange<Int>, message: String? = nil) -> ValidationRule<Int> {
        ValidationRule(
            validate: { range.contains($0) },
            message: message ?? "Value must be between \(range.lowerBound) and \(range.upperBound)"
        )
    }
    
    static func nonZero(message: String? = nil) -> ValidationRule<Int> {
        ValidationRule(
            validate: { $0 != 0 },
            message: message ?? "Value cannot be zero"
        )
    }
}

// MARK: - Validation State
enum ValidationState: Equatable {
    case valid
    case invalid(message: String)
    case notValidated
    
    var isValid: Bool {
        if case .valid = self { return true }
        return false
    }
    
    var message: String? {
        if case .invalid(let message) = self { return message }
        return nil
    }
}

// MARK: - Validation Mode
enum ValidationMode {
    case onSubmit
    case onBlur
    case onChange
}

// MARK: - Validated Field
@propertyWrapper
struct ValidatedField<T>: DynamicProperty {
    private final class Storage: ObservableObject {
        @Published var value: T
        @Published var state: ValidationState = .notValidated
        
        init(value: T) {
            self.value = value
        }
    }
    
    @StateObject private var storage: Storage
    
    let mode: ValidationMode
    private var rules: [ValidationRule<T>]
    
    var wrappedValue: T {
        get { storage.value }
        set {
            storage.value = newValue
            if mode == .onChange {
                _ = validate()
            }
        }
    }
    
    var projectedValue: Binding<T> {
        Binding(
            get: { self.storage.value },
            set: {
                self.storage.value = $0
                if self.mode == .onChange {
                    _ = self.validate()
                }
            }
        )
    }
    
    init(wrappedValue: T, mode: ValidationMode = .onSubmit, rules: ValidationRule<T>...) {
        self._storage = StateObject(wrappedValue: Storage(value: wrappedValue))
        self.mode = mode
        self.rules = rules
    }
    
    var state: ValidationState {
        storage.state
    }
    
    func validate() -> Bool {
        for rule in rules {
            if !rule.validate(storage.value) {
                storage.state = .invalid(message: rule.message)
                return false
            }
        }
        storage.state = .valid
        return true
    }
    
    func reset() {
        storage.state = .notValidated
    }
}

protocol ValidatedFieldProtocol {
    func validate() -> Bool
    func reset()
}

extension ValidatedField: ValidatedFieldProtocol {}

class AnyValidatedField: ValidatedFieldProtocol {
    private let _validate: () -> Bool
    private let _reset: () -> Void
    
    init(_ field: any ValidatedFieldProtocol) {
        self._validate = { field.validate() }
        self._reset = { field.reset() }
    }
    
    func validate() -> Bool {
        _validate()
    }
    
    func reset() {
        _reset()
    }
}

// Make ValidatedField conform to ValidatedFieldProtocol
//extension ValidatedField: ValidatedFieldProtocol {}

// Extension to get the projected value from a property wrapper
extension ValidatedField {
    var projectedValidatedField: ValidatedField<T> {
        return self
    }
}

// MARK: - Form Validator
class FormValidator: ObservableObject {
    private var fields: [AnyValidatedField] = []
    
    func add(_ fields: any ValidatedFieldProtocol...) {
        fields.forEach { field in
            self.fields.append(AnyValidatedField(field))
        }
    }
    
    func validateAll() -> Bool {
        return fields.allSatisfy { $0.validate() }
    }
    
    func resetAll() {
        fields.forEach { $0.reset() }
    }
}

// MARK: - Validated TextField
struct ValidatedTextField<T: LosslessStringConvertible, TextFieldView: View>: View {
    let title: String
    var field: ValidatedField<T>
    let onBlur: (() -> Void)?
    let textFieldContent: (Binding<T>) -> TextFieldView
    
    init(
        title: String,
        field: ValidatedField<T>,
        onBlur: (() -> Void)? = nil,
        @ViewBuilder textField: @escaping (Binding<T>) -> TextFieldView
    ) {
        self.title = title
        self.field = field
        self.onBlur = onBlur
        self.textFieldContent = textField
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            textFieldContent(field.projectedValue)
                .onSubmit {
                    if field.mode == .onBlur {
                        _ = field.validate()
                    }
                    onBlur?()
                }
            
            if case .invalid(let message) = field.state {
                Text(message)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
}

// MARK: - Usage Example
/*
struct Example: View {
    @StateObject private var formValidator = FormValidator()
    
    @ValidatedField(
        wrappedValue: 0.0,
        mode: .onChange,
        rules: .min(30, message: "Weight must be at least 30kg"),
              .max(300, message: "Weight must be at most 300kg")
    ) var weight: Double
    
    @ValidatedField(
        wrappedValue: 0.0,
        mode: .onBlur,
        rules: .range(100...250, message: "Height must be between 100cm and 250cm")
    ) var height: Double
    
    @ValidatedField(
        wrappedValue: 0.0,
        mode: .onChange,
        rules: .range(1.2...2.4, message: "Activity level must be between 1.2 and 2.4")
    ) var activityLevel: Double
    
    var body: some View {
        Form {
            Section("Body Measurements") {
                ValidatedTextField(
                    title: "Weight (kg)",
                    field: $weight
                )
                
                ValidatedTextField(
                    title: "Height (cm)",
                    field: $height
                )
                
                ValidatedTextField(
                    title: "Activity Level",
                    field: $activityLevel
                )
            }
            
            Button("Save") {
                if formValidator.validateAll() {
                    // Save changes
                }
            }
        }
        .onAppear {
            formValidator.add($weight)
            formValidator.add($height)
            formValidator.add($activityLevel)
        }
    }
}
*/
