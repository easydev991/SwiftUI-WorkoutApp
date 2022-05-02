//
//  EditAccountView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 17.04.2022.
//

import SwiftUI

struct EditAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userDefaults: UserDefaultsService
    @StateObject private var viewModel = EditAccountViewModel()
    @FocusState private var focus: FocusableField?

    var body: some View {
        Form {
            Section {
                loginField()
                emailField()
                if !userDefaults.isUserAuthorized {
                    passwordField()
                }
                nameField()
                genderPicker()
                birthdayPicker()
                countryPicker()
                cityPicker()
            }
            if !userDefaults.isUserAuthorized {
                Section {
                    rulesOfService()
                }
                Section {
                    registerButton()
                }
            } else {
                Section {
                    saveChangesButton()
                }
            }
        }
        .navigationTitle(viewModel.title(userDefaults.isUserAuthorized))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension EditAccountView {
    enum FocusableField: Hashable {
        case login, email, password
    }

    func loginField() -> some View {
        HStack {
            Image(systemName: "person")
                .foregroundColor(.secondary)
            TextField("Логин", text: $viewModel.loginText)
                .focused($focus, equals: .login)
        }
    }

    func emailField() -> some View {
        HStack {
            Image(systemName: "envelope")
                .foregroundColor(.secondary)
            TextField("email", text: $viewModel.emailText)
                .focused($focus, equals: .email)
        }
    }

    func passwordField() -> some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.secondary)
            SecureField("Пароль (минимум 6 символов)", text: $viewModel.passwordText)
                .focused($focus, equals: .password)
        }
    }

    func nameField() -> some View {
        HStack {
            Image(systemName: "person")
                .foregroundColor(.secondary)
            TextField("Имя (необязательно)", text: $viewModel.nameText)
        }
    }

    func countryPicker() -> some View {
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

    func cityPicker() -> some View {
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

    func genderPicker() -> some View {
        Menu {
            Picker("", selection: $viewModel.selectedGender) {
                ForEach($viewModel.genders, id: \.self) {
                    Text($0.wrappedValue)
                }
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

    func birthdayPicker() -> some View {
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

    func rulesOfService() -> some View {
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

    func registerButton() -> some View {
        Button {
            viewModel.registerAction()
            focus = nil
        } label: {
            ButtonInFormLabel(title: "Зарегистрироваться")
        }
        .disabled(!viewModel.isButtonAvailable(with: userDefaults.isUserAuthorized))
    }

    func saveChangesButton() -> some View {
        Button {
            viewModel.saveChangesAction()
            dismiss()
        } label: {
            ButtonInFormLabel(title: "Сохранить")
        }
        .disabled(!viewModel.isButtonAvailable(with: userDefaults.isUserAuthorized))
    }
}

struct EditAccountView_Previews: PreviewProvider {
    static var previews: some View {
        EditAccountView()
            .environmentObject(UserDefaultsService())
    }
}
