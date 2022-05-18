//
//  AccountInfoView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 17.04.2022.
//

import SwiftUI

struct AccountInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = AccountInfoViewModel()
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var registrationTask: Task<Void, Never>?
    @State private var editUserTask: Task<Void, Never>?
    @FocusState private var focus: FocusableField?

    var body: some View {
        ZStack {
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
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .disabled(viewModel.isLoading)
        .task {
            await viewModel.updateFormIfNeeded(with: defaults)
        }
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button(action: viewModel.clearErrorMessage) { TextOk() }
        }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: viewModel.isProfileSaved, perform: close)
        .onDisappear(perform: cancelTasks)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension AccountInfoView {
    enum FocusableField: Hashable {
        case login, email, password
    }

    var loginField: some View {
        HStack {
            Image(systemName: "person")
                .foregroundColor(.secondary)
            TextField(viewModel.userForm.placeholder(.userName), text: $viewModel.userForm.userName)
                .focused($focus, equals: .login)
        }
    }

    var emailField: some View {
        HStack {
            Image(systemName: "envelope")
                .foregroundColor(.secondary)
            TextField(viewModel.userForm.placeholder(.email), text: $viewModel.userForm.email)
                .focused($focus, equals: .email)
        }
    }

    var passwordField: some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.secondary)
            SecureField(viewModel.userForm.placeholder(.password), text: $viewModel.userForm.password)
                .focused($focus, equals: .password)
        }
    }

    var nameField: some View {
        HStack {
            Image(systemName: "person")
                .foregroundColor(.secondary)
            TextField(viewModel.userForm.placeholder(.fullname), text: $viewModel.userForm.fullName)
        }
    }

    var countryPicker: some View {
        NavigationLink(destination: CountriesView(viewModel: viewModel)) {
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(.secondary)
                Text(viewModel.userForm.placeholder(.country))
                Spacer()
                Text(viewModel.userForm.country.name)
                    .foregroundColor(.secondary)
            }
        }
    }

    var cityPicker: some View {
        NavigationLink(destination: CitiesView(viewModel: viewModel)) {
            HStack {
                Image(systemName: "signpost.right")
                    .foregroundColor(.secondary)
                Text(viewModel.userForm.placeholder(.city))
                Spacer()
                Text(viewModel.userForm.city.name)
                    .foregroundColor(.secondary)
            }
        }
    }

    var genderPicker: some View {
        Menu {
            Picker("", selection: $viewModel.userForm.genderCode) {
                ForEach(Constants.Gender.allCases.map(\.code), id: \.self) {
                    Text(Constants.Gender($0).rawValue)
                }
            }
        } label: {
            HStack {
                Image(systemName: "person.fill.questionmark")
                    .foregroundColor(.secondary)
                Text(viewModel.userForm.placeholder(.gender))
                Spacer()
                Text(Constants.Gender(viewModel.userForm.genderCode).rawValue)
                    .foregroundColor(.secondary)
            }
        }
    }

    var birthdayPicker: some View {
        HStack {
            Image(systemName: "face.smiling")
                .foregroundColor(.secondary)
            DatePicker(
                viewModel.userForm.placeholder(.birthDate),
                selection: $viewModel.userForm.birthDate,
                in: ...Constants.minUserAge,
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
            .disabled(!viewModel.isButtonAvailable(with: defaults))
        }
    }

    func registerAction() {
        focus = nil
        registrationTask = Task { await viewModel.registerAction(with: defaults) }
    }

    var saveChangesButtonSection: some View {
        Section {
            Button(action: saveChangesAction) {
                ButtonInFormLabel(title: "Сохранить")
            }
            .disabled(!viewModel.isButtonAvailable(with: defaults))
        }
    }

    func saveChangesAction() {
        editUserTask = Task { await viewModel.saveChangesAction(with: defaults) }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    func close(_ shouldClose: Bool) {
        if shouldClose { dismiss() }
    }

    func cancelTasks() {
        [registrationTask, editUserTask].forEach { $0?.cancel() }
    }
}

struct EditAccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountInfoView()
            .environmentObject(DefaultsService())
    }
}
