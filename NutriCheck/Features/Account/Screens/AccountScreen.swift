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
    @StateObject private var preferences = PreferencesQueries.getPreferences()
    
    @State private var showEditProfile = false
    @State private var showEditPreferences = false
    
    let preferencesState: Preferences = .init(activityLevel: 10, gender: .male, age: 20, weight: 100, height: 200, diet: .noDiet, allergens: [])

    var body: some View {
        NavigationStack {
            withCombinedQueries(account, preferences) {
                ProgressView()
            } success: { account, preferences in
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
                        Button {
                            showEditPreferences.toggle()
                        } label: {
                            HStack {
                                Label("Edit preferences", systemImage: "carrot")
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
                .sheet(isPresented: $showEditProfile) {
                    EditProfileScreen(account: account)
                        .presentationBackground(.ultraThinMaterial)
                }
                .sheet(isPresented: $showEditPreferences) {
                    //                TestView(preferences: preferencesState)
                    //                EditPreferencesScreen(preferences: preferencesState)
                    //                EditPreferencesScreen(preferences: preferences.state.value!)
                    EditPreferencesScreen(
                        preferences: .init(
                            activityLevel: preferences.activityLevel,
                            gender: preferences.gender,
                            age: preferences.age,
                            weight: preferences.weight ?? 100,
                            height: preferences.height ?? 200,
                            diet: preferences.diet,
                            allergens: preferences.allergens
                        )
                    )
                    .presentationBackground(.ultraThinMaterial)
                }
                .navigationTitle("Account")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AccountScreen()
}

@propertyWrapper
struct MyWrapper<Value>: DynamicProperty {
    @StateObject private var storage: Storage
    
    private final class Storage: ObservableObject {
        @Published var value: Value
        
        init(value: Value) {
            self.value = value
        }
    }
    
    init(wrappedValue: Value) {
        _storage = StateObject(wrappedValue: Storage(value: wrappedValue))
    }
    
    var wrappedValue: Value {
        get { storage.value }
        set { storage.value = newValue }
    }
    
    var projectedValue: Binding<Value> {
        Binding(
            get: { storage.value },
            set: { storage.value = $0 }
        )
    }
}

struct TestView: View {
    @State private var textState: String = ""
    @MyWrapper private var text: String = ""
    
    init(preferences: Preferences) {
//        self._text = MyWrapper(wrappedValue: "")
    }
    
    var body: some View {
        VStack {
            TextField("text", text: $text)
            TextField("text", text: $textState)
        }
    }
}

struct EditPreferencesScreen: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentToast) var presentToast
    
    @StateObject private var formValidator = FormValidator()
    @StateObject private var updatePreferences = PreferencesQueries.updatePreferences()
    
    @ValidatedField private var gender: Gender
    @ValidatedField private var age: Int
    @ValidatedField private var weight: Double
    @ValidatedField private var height: Double
    @ValidatedField private var activityLevel: Double
    @ValidatedField private var diet: DietType
    
    @State private var allergens: Set<String> = []
    
    init(preferences: Preferences) {
        _gender = ValidatedField(
            wrappedValue: preferences.gender,
            mode: .onChange
        )
        _age = ValidatedField(
            wrappedValue: preferences.age,
            mode: .onBlur,
            rules: .range(0 ... 120)
        )
        _weight = ValidatedField(
            wrappedValue: preferences.weight ?? 0.0,
            mode: .onChange,
            rules: .range(30 ... 300)
        )
        _height = ValidatedField(
            wrappedValue: preferences.height ?? 0.0,
            mode: .onBlur,
            rules: .range(100 ... 250)
        )
        _activityLevel = ValidatedField(
            wrappedValue: preferences.activityLevel ?? 1.2,
            rules: .range(1.0 ... 2.4)
        )
        _diet = ValidatedField(wrappedValue: preferences.diet)
        _allergens = State(initialValue: Set(preferences.allergens))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    Picker("Gender", selection: $gender) {
                        Text("Male").tag(Gender.male)
                        Text("Female").tag(Gender.female)
                    }

                    ValidatedTextField(title: "Age", field: _age) { value in
                        HStack {
                            Text("Age")
                            TextField("Age", value: value, format: .number)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                        }
                    }
                }

                Section("Body Measurements") {
                    ValidatedTextField(
                        title: "Weight",
                        field: _weight
                    ) { value in
                        HStack {
                            Text("Weight")
                            TextField("Weight", value: value, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            Text("kg")
                        }
                    }

                    ValidatedTextField(
                        title: "Height",
                        field: _height
                    ) { value in
                        HStack {
                            Text("Height")
                            TextField("Height", value: value, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                            Text("cm")
                        }
                    }

                    Picker(
                        "Activity Level",
                        selection: $activityLevel
                    ) {
                        Text("Extremely Inactive").tag(1.0)
                        Text("Sedentary").tag(1.4)
                        Text("Moderately Active").tag(1.7)
                        Text("Vigurously Active").tag(2.0)
                        Text("Extremely Active").tag(2.4)
                    }
                }

                Section("Diet Preferences") {
                    Picker("Diet Type", selection: $diet) {
                        Text("No diet").tag(DietType.noDiet)
                        Text("Vegetarian").tag(DietType.vegetarian)
                        Text("Vegan").tag(DietType.vegan)
                        Text("Pescatarian").tag(DietType.pescatarian)
                    }
                }

                Section("Allergens") {
                    ForEach(Allergen.allCases, id: \.self) { allergen in
                        CheckboxView(
                            title: allergen.rawValue.capitalized,
                            isChecked: allergens.contains(allergen.rawValue)
                        ) {
                            if allergens.contains(allergen.rawValue) {
                                allergens.remove(allergen.rawValue)
                            } else {
                                allergens.insert(allergen.rawValue)
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.immediately)
            .listSectionSpacing(4)
            .navigationTitle("Edit Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if formValidator.validateAll() {
                            let updatedPreferences = Preferences(
                                activityLevel: activityLevel,
                                gender: gender,
                                age: age,
                                weight: weight,
                                height: height,
                                diet: diet,
                                allergens: Array(allergens)
                            )
                            
                            Task {
                                updatePreferences
                                    .execute(
                                        updatedPreferences,
                                        presenting: presentToast,
                                        successMessage: "Preferences updated successfully",
                                        errorTransform: { "\($0.localizedDescription)" },
                                        onSuccess: { _ in
                                            dismiss()
                                        }
                                    )
                            }
                        }
                    }
                    .disabled(updatePreferences.state.isLoading)
                }
            }
            .onAppear {
                formValidator.add(_gender, _age, _weight, _height, _activityLevel, _diet)
            }
        }
    }
}

struct CheckboxView: View {
    let title: String
    let isChecked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(isChecked ? .blue : .gray)
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
            }
            .contentShape(Rectangle())
        }
    }
}
