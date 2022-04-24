//
//  EditAccountView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 17.04.2022.
//

import SwiftUI

struct EditAccountView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    @State private var loginText = ""
    @State private var emailText = ""
    @State private var passwordText = ""
    @State private var nameText = ""
    @State private var birthDate = Date()
    @FocusState private var focus: FocusableField?
    private var maxDate: Date {
        Calendar.current.date(
            byAdding: .year,
            value: Constants.minimumUserAge,
            to: .now
        ) ?? .now
    }

    var body: some View {
        Form {
            Section {
                loginField()
                emailField()
                if !appState.isUserAuthorized {
                    passwordField()
                }
                nameField()
                countryPicker()
                cityPicker()
                genderPicker()
                birthdayPicker()
            }
            if !appState.isUserAuthorized {
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
        .navigationTitle(viewTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension EditAccountView {
    enum FocusableField: Hashable {
        case login, email, password
    }

    var viewTitle: String {
        appState.isUserAuthorized ? "Изменить профиль" : "Регистрация"
    }

    func loginField() -> some View {
        HStack {
            Image(systemName: "person")
                .foregroundColor(.secondary)
            TextField("Логин", text: $loginText)
                .focused($focus, equals: .login)
        }
    }

    func emailField() -> some View {
        HStack {
            Image(systemName: "envelope")
                .foregroundColor(.secondary)
            TextField("email", text: $emailText)
                .focused($focus, equals: .email)
        }
    }

    func passwordField() -> some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.secondary)
            SecureField("Пароль (минимум 6 символов)", text: $passwordText)
                .focused($focus, equals: .password)
        }
    }

    func nameField() -> some View {
        HStack {
            Image(systemName: "person")
                .foregroundColor(.secondary)
            TextField("Имя (необязательно)", text: $nameText)
        }
    }

    func countryPicker() -> some View {
        NavigationLink(destination: CountriesView(countriesList: appState.countries)) {
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(.secondary)
                Text("Страна")
                Spacer()
                Text($appState.selectedCountry.wrappedValue.name)
                    .foregroundColor(.secondary)
            }
        }
    }

    func cityPicker() -> some View {
        NavigationLink(destination: CitiesView(cities: appState.cities)) {
            HStack {
                Image(systemName: "signpost.right")
                    .foregroundColor(.secondary)
                Text("Город")
                Spacer()
                Text($appState.selectedCity.wrappedValue.name)
                    .foregroundColor(.secondary)
            }
        }
    }

    func genderPicker() -> some View {
        Picker(selection: $appState.selectedGender) {
            ForEach($appState.genders, id: \.self) {
                Text($0.wrappedValue)
            }
        } label: {
            HStack {
                Image(systemName: "person.fill.questionmark")
                    .foregroundColor(.secondary)
                Text("Пол")
            }
        }
    }

    func birthdayPicker() -> some View {
        HStack {
            Image(systemName: "face.smiling")
                .foregroundColor(.secondary)
            DatePicker("Дата рождения", selection: $birthDate, in: ...maxDate, displayedComponents: .date)
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
#warning("TODO: интеграция с сервером")
#warning("TODO: Проверить введенные данные")
            print("--- Проверяем введенные данные и начинаем регистрацию")
            focus = nil
        } label: {
            ButtonInFormLabel(title: "Зарегистрироваться")
        }
        .disabled(
            loginText.isEmpty || emailText.isEmpty || passwordText.count < 6
        )
    }

    func saveChangesButton() -> some View {
        Button {
#warning("TODO: интеграция с сервером")
#warning("TODO: интеграция с БД")
            // Сохранить изменения профиля
            presentationMode.wrappedValue.dismiss()
        } label: {
            ButtonInFormLabel(title: "Сохранить")
        }
        .disabled(true)
    }
}

struct EditAccountView_Previews: PreviewProvider {
    static var previews: some View {
        EditAccountView()
            .environmentObject(AppState())
    }
}
