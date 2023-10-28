import NetworkStatus
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран для изменения личных данных пользователя
struct EditAccountScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    @State private var userForm = MainUserForm.emptyValue
    /// Ранее сохраненная форма с данными пользователя
    @State private var oldUserForm = MainUserForm.emptyValue
    /// Все доступные страны и города
    @State private var locations = Locations(countries: [])
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var editUserTask: Task<Void, Never>?
    @FocusState private var focus: FocusableField?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                Group {
                    loginField.padding(.top)
                    emailField
                    nameField
                    changePasswordButton
                }
                .padding(.bottom, 12)
                genderPicker
                birthdayPicker
                countryPicker
                cityPicker
            }
            Spacer()
            saveChangesButton
        }
        .padding([.horizontal, .bottom])
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button("Ok") { alertMessage = "" }
        }
        .onAppear(perform: prepareLocationsAndUserForm)
        .onDisappear { editUserTask?.cancel() }
        .navigationTitle("Изменить профиль")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension EditAccountScreen {
    enum FocusableField: Hashable {
        case login, email, fullName
    }

    var loginField: some View {
        SWTextField(
            placeholder: userForm.placeholder(.userName),
            text: $userForm.userName,
            isFocused: focus == .login
        )
        .focused($focus, equals: .login)
    }

    var emailField: some View {
        SWTextField(
            placeholder: userForm.placeholder(.email),
            text: $userForm.email,
            isFocused: focus == .email
        )
        .focused($focus, equals: .email)
    }

    var nameField: some View {
        SWTextField(
            placeholder: userForm.placeholder(.fullname),
            text: $userForm.fullName,
            isFocused: focus == .fullName
        )
        .focused($focus, equals: .fullName)
    }

    var changePasswordButton: some View {
        NavigationLink(destination: ChangePasswordView()) {
            ListRowView(leadingContent: .iconWithText(.key, "Изменить пароль"), trailingContent: .chevron)
        }
    }

    var genderPicker: some View {
        Menu {
            Picker("", selection: $userForm.genderCode) {
                ForEach(Gender.possibleGenders, id: \.code) {
                    Text(.init($0.rawValue))
                }
            }
        } label: {
            ListRowView(
                leadingContent: .iconWithText(
                    .personQuestion,
                    userForm.placeholder(.gender)
                ),
                trailingContent: .textWithChevron(.init(userForm.genderString))
            )
        }
    }

    var birthdayPicker: some View {
        HStack(spacing: 12) {
            ListRowView.LeadingContent.makeIconView(with: Icons.Regular.calendar)
            DatePicker(
                .init(userForm.placeholder(.birthDate)),
                selection: $userForm.birthDate,
                in: ...Constants.minUserAge,
                displayedComponents: .date
            )
        }
        .padding(.vertical, 16)
    }

    var countryPicker: some View {
        NavigationLink {
            ItemListScreen(
                mode: .country,
                allItems: locations.countries.map(\.name),
                selectedItem: userForm.country.name,
                didSelectItem: selectCountry
            )
        } label: {
            ListRowView(
                leadingContent: .iconWithText(
                    .globe,
                    userForm.placeholder(.country)
                ),
                trailingContent: .textWithChevron(.init(userForm.country.name))
            )
        }
        .padding(.bottom, 6)
    }

    var cityPicker: some View {
        NavigationLink {
            ItemListScreen(
                mode: .city,
                allItems: locations.cities.map(\.name),
                selectedItem: userForm.city.name,
                didSelectItem: selectCity
            )
        } label: {
            ListRowView(
                leadingContent: .iconWithText(
                    .signPost,
                    userForm.placeholder(.city)
                ),
                trailingContent: .textWithChevron(.init(userForm.city.name))
            )
        }
    }

    var saveChangesButton: some View {
        Button("Сохранить", action: saveChangesAction)
            .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
            .disabled(
                !userForm.isReadyToSave(comparedTo: oldUserForm)
                    || !network.isConnected
            )
    }

    func prepareLocationsAndUserForm() {
        guard locations.isEmpty else { return }
        do {
            locations = try .init()
            if let userInfo = defaults.mainUserInfo {
                oldUserForm = .init(userInfo)
                oldUserForm.country = locations.countries
                    .first(where: { $0.id == oldUserForm.country.id }) ?? .defaultCountry
                oldUserForm.city = locations.cities
                    .first(where: { $0.id == oldUserForm.city.id }) ?? .defaultCity
                userForm = oldUserForm
            }
        } catch {
            setupErrorAlert(with: error.localizedDescription)
        }
    }

    func selectCountry(name countryName: String) {
        let newCountry = locations.countries
            .first(where: { $0.name == countryName }) ?? .defaultCountry
        userForm.country = newCountry
        if !newCountry.cities.contains(where: { $0 == userForm.city }),
           let firstCity = newCountry.cities.first {
            userForm.city = firstCity
            locations.cities = newCountry.cities
        }
    }

    func selectCity(name cityName: String) {
        userForm.city = locations.cities
            .first(where: { $0.name == cityName }) ?? .defaultCity
    }

    func saveChangesAction() {
        isLoading = true
        editUserTask = Task {
            do {
                let userID = defaults.mainUserInfo?.id ?? 0
                if try await SWClient(with: defaults).editUser(userID, model: userForm) {
                    dismiss()
                }
            } catch {
                setupErrorAlert(with: ErrorFilter.message(from: error))
            }
            isLoading = false
        }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }
}

private extension EditAccountScreen {
    struct Locations {
        /// Все доступные страны
        var countries: [Country]
        /// Все доступные города
        var cities: [City]

        init(countries: [Country]) {
            self.countries = countries
            self.cities = countries.flatMap(\.cities)
        }

        /// Инициализирует модель данными из сохраненного `JSON`, если это возможно
        init() throws {
            let allCountries = try SWAddress().countries()
            self.init(countries: allCountries)
        }

        var isEmpty: Bool {
            countries.isEmpty && cities.isEmpty
        }
    }
}

#if DEBUG
#Preview {
    NavigationView {
        EditAccountScreen()
            .environmentObject(NetworkStatus())
            .environmentObject(DefaultsService())
    }
}
#endif
