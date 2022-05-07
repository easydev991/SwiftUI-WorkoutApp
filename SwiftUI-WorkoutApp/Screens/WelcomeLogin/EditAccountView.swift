//
//  EditAccountView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 17.04.2022.
//

import SwiftUI

struct EditAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: UserDefaultsService
    @StateObject private var viewModel = EditAccountViewModel()
    @FocusState private var focus: FocusableField?

    var body: some View {
        Form {
            Section {
                loginField
                emailField
                if !defaults.isAuthorized {
                    passwordField
                }
                nameField
                genderPicker
                birthdayPicker
                countryPicker
                cityPicker
            }
            if !defaults.isAuthorized {
                rulesOfServiceSection
                registerButtonSection
            } else {
                saveChangesButtonSection
            }
        }
        .navigationTitle(viewModel.title(defaults.isAuthorized))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension EditAccountView {
    enum FocusableField: Hashable {
        case login, email, password
    }

    var loginField: some View {
        HStack {
            Image(systemName: "person")
                .foregroundColor(.secondary)
            TextField("Логин", text: $viewModel.loginText)
                .focused($focus, equals: .login)
        }
    }

    var emailField: some View {
        HStack {
            Image(systemName: "envelope")
                .foregroundColor(.secondary)
            TextField("email", text: $viewModel.emailText)
                .focused($focus, equals: .email)
        }
    }

    var passwordField: some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.secondary)
            SecureField("Пароль (минимум 6 символов)", text: $viewModel.passwordText)
                .focused($focus, equals: .password)
        }
    }

    var nameField: some View {
        HStack {
            Image(systemName: "person")
                .foregroundColor(.secondary)
            TextField("Имя (необязательно)", text: $viewModel.nameText)
        }
    }

    var countryPicker: some View {
        NavigationLink(destination: CountriesView(viewModel: viewModel)) {
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(.secondary)
                Text("Страна")
                Spacer()
                Text($viewModel.selectedCountry.wrappedValue.name)
                    .foregroundColor(.secondary)
            }
        }
    }

    var cityPicker: some View {
        NavigationLink(destination: CitiesView(viewModel: viewModel)) {
            HStack {
                Image(systemName: "signpost.right")
                    .foregroundColor(.secondary)
                Text("Город")
                Spacer()
                Text($viewModel.selectedCity.wrappedValue.name)
                    .foregroundColor(.secondary)
            }
        }
    }

    var genderPicker: some View {
        Menu {
            Picker("", selection: $viewModel.selectedGender) {
                ForEach($viewModel.genders, id: \.self) { Text($0.wrappedValue) }
            }
        } label: {
            HStack {
                Image(systemName: "person.fill.questionmark")
                    .foregroundColor(.secondary)
                Text("Пол")
                Spacer()
                Text(viewModel.selectedGender)
                    .foregroundColor(.secondary)
            }
        }
    }

    var birthdayPicker: some View {
        HStack {
            Image(systemName: "face.smiling")
                .foregroundColor(.secondary)
            DatePicker(
                "Дата рождения",
                selection: $viewModel.birthDate,
                in: ...viewModel.maxDate,
                displayedComponents: .date
            )
        }
    }

    var rulesOfServiceSection: some View {
        Section {
            Link(destination: URL(string: Constants.rulesOfService)!) {
                HStack {
                    Spacer()
                    Text("Регистрируясь, вы соглашаетесь с нашим пользовательским соглашением")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.blue)
                    Spacer()
                }
            }
        }
    }

    var registerButtonSection: some View {
        Section {
            Button(action: registerAction) {
                ButtonInFormLabel(title: "Зарегистрироваться")
            }
            .disabled(!viewModel.isButtonAvailable(defaults.isAuthorized))
        }
    }

    func registerAction() {
        viewModel.registerAction()
        focus = nil
    }

    var saveChangesButtonSection: some View {
        Section {
            Button(action: saveChangesAction) {
                ButtonInFormLabel(title: "Сохранить")
            }
            .disabled(!viewModel.isButtonAvailable(defaults.isAuthorized))
        }
    }

    func saveChangesAction() {
        viewModel.saveChangesAction()
        dismiss()
    }
}

struct EditAccountView_Previews: PreviewProvider {
    static var previews: some View {
        EditAccountView()
            .environmentObject(UserDefaultsService())
    }
}
