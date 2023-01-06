import SwiftUI

/// Экран для регистрации пользователя или изменения его личных данных
struct AccountInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var network: CheckNetworkService
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = AccountInfoViewModel()
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var registrationTask: Task<Void, Never>?
    @State private var editUserTask: Task<Void, Never>?
    @FocusState private var focus: FocusableField?
    let mode: Mode

    var body: some View {
        Form {
            Section {
                loginField
                emailField
                if mode == .create {
                    passwordField
                }
                nameField
                genderPicker
                birthdayPicker
                countryPicker
                cityPicker
            }
            if mode == .create {
                rulesOfServiceSection
                registerButtonSection
            } else {
                saveChangesButtonSection
            }
        }
        .opacity(viewModel.isLoading ? 0.5 : 1)
        .overlay {
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : 0)
        }
        .animation(.default, value: viewModel.isLoading)
        .disabled(viewModel.isLoading)
        .task {
            await viewModel.updateFormIfNeeded(with: defaults)
        }
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button("Ok") { viewModel.clearErrorMessage() }
        }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: viewModel.isProfileSaved, perform: close)
        .onDisappear(perform: cancelTasks)
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension AccountInfoView {
    enum Mode: CaseIterable {
        /// Создание аккаунта
        case create
        /// Изменение личных данных
        case edit
    }
}

private extension AccountInfoView.Mode {
    var title: String {
        self == .create ? "Регистрация" : "Изменить профиль"
    }
}

private extension AccountInfoView {
    enum FocusableField: Hashable {
        case login, email, password, fullName
    }

    var loginField: some View {
        TextFieldInForm(
            mode: .regular(systemImageName: "person"),
            placeholder: viewModel.userForm.placeholder(.userName),
            text: $viewModel.userForm.userName
        )
        .focused($focus, equals: .login)
    }

    var emailField: some View {
        TextFieldInForm(
            mode: .regular(systemImageName: "envelope"),
            placeholder: viewModel.userForm.placeholder(.email),
            text: $viewModel.userForm.email
        )
        .focused($focus, equals: .email)
    }

    var passwordField: some View {
        TextFieldInForm(
            mode: .secure,
            placeholder: viewModel.userForm.placeholder(.password),
            text: $viewModel.userForm.password
        )
        .focused($focus, equals: .password)
    }

    var nameField: some View {
        TextFieldInForm(
            mode: .regular(systemImageName: "person"),
            placeholder: viewModel.userForm.placeholder(.fullname),
            text: $viewModel.userForm.fullName
        )
        .focused($focus, equals: .fullName)
    }

    var countryPicker: some View {
        NavigationLink {
            CountriesView(
                allCountries: $viewModel.countries,
                selectedCountry: viewModel.userForm.country,
                countryClbk: { viewModel.selectCountry($0) }
            )
        } label: {
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
        NavigationLink {
            CitiesView(
                allCities: $viewModel.cities,
                selectedCity: viewModel.userForm.city,
                cityClbk: { viewModel.selectCity($0) }
            )
        } label: {
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
                ForEach(Gender.allCases.map(\.code), id: \.self) {
                    Text(Gender($0).rawValue)
                }
            }
        } label: {
            HStack {
                Image(systemName: "person.fill.questionmark")
                    .foregroundColor(.secondary)
                Text(viewModel.userForm.placeholder(.gender))
                Spacer()
                Text(Gender(viewModel.userForm.genderCode).rawValue)
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
            Link(destination: Constants.rulesOfService) {
                Text("Регистрируясь, вы соглашаетесь с нашим пользовательским соглашением")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    var registerButtonSection: some View {
        Section {
            ButtonInForm("Зарегистрироваться", action: registerAction)
                .disabled(!viewModel.isButtonAvailable(with: defaults))
        }
    }

    func registerAction() {
        focus = nil
        registrationTask = Task { await viewModel.registerAction(with: defaults) }
    }

    var saveChangesButtonSection: some View {
        Section {
            ButtonInForm("Сохранить", action: saveChangesAction)
                .disabled(
                    !viewModel.isButtonAvailable(with: defaults)
                    || !network.isConnected
                )
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
        ForEach(AccountInfoView.Mode.allCases, id: \.title) { mode in
            NavigationView {
                AccountInfoView(mode: mode)
                    .environmentObject(CheckNetworkService())
                    .environmentObject(DefaultsService())
            }
        }
    }
}
