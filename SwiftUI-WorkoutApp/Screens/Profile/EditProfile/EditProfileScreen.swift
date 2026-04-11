import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран для изменения личных данных пользователя
struct EditProfileScreen: View {
    @Environment(\.analyticsService) private var analytics
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @EnvironmentObject private var parksManager: ParksManager
    @State private var userForm = MainUserForm.emptyValue
    /// Ранее сохраненная форма с данными пользователя
    @State private var oldUserForm = MainUserForm.emptyValue
    /// Все доступные страны и города
    @State private var locations = EditProfileLocations(countries: [])
    @State private var isLoading = false
    @State private var editUserTask: Task<Void, Never>?
    @State private var newAvatarImageModel: AvatarModel?
    @State private var showImagePickerDialog = false
    @State private var pickerSourceType: UIImagePickerController.SourceType?
    @FocusState private var focus: FocusableField?

    var body: some View {
        VStack(spacing: 12) {
            ScrollView {
                VStack(spacing: 12) {
                    avatarPicker
                    loginField
                    emailField
                    nameField
                    changePasswordButton
                    VStack(spacing: 4) {
                        genderPicker
                        birthdayPicker
                        countryPicker
                        cityPicker
                    }
                }
                .padding()
            }
            saveChangesButton
        }
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .onAppear(perform: prepareLocationsAndUserForm)
        .onDisappear { editUserTask?.cancel() }
        .navigationTitle("Изменить профиль")
        .navigationBarTitleDisplayMode(.inline)
        .trackScreen(.editProfile)
    }
}

private extension EditProfileScreen {
    enum FocusableField: Hashable {
        case login, email, fullName
    }

    struct AvatarModel: Equatable {
        let id = UUID().uuidString
        let uiImage: UIImage
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
        NavigationLink(destination: ChangePasswordScreen()) {
            ListRowView(leadingContent: .iconWithText(.key, "Изменить пароль"), trailingContent: .chevron)
        }
    }

    var avatarPicker: some View {
        VStack(spacing: 20) {
            Group {
                if let model = newAvatarImageModel {
                    Image(uiImage: model.uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(.rect(cornerRadius: 12))
                        .transition(.scale.combined(with: .slide).combined(with: .opacity))
                        .id(model.id)
                } else {
                    CachedImage(url: defaults.mainUserInfo?.avatarURL, mode: .profileAvatar)
                        .transition(.scale.combined(with: .slide).combined(with: .opacity))
                }
            }
            .accessibilityLabel(Text("Фото профиля"))
            Button("Изменить фотографию") { showImagePickerDialog.toggle() }
                .buttonStyle(SWButtonStyle(mode: .tinted, size: .large, maxWidth: nil))
                .padding(.bottom, 8)
                .confirmationDialog(
                    "",
                    isPresented: $showImagePickerDialog,
                    titleVisibility: .hidden
                ) {
                    Button("Сделать фото") {
                        pickerSourceType = .camera
                    }
                    Button("Выбрать из галереи") {
                        pickerSourceType = .photoLibrary
                    }
                }
        }
        .animation(.default, value: newAvatarImageModel)
        .fullScreenCover(item: $pickerSourceType) { sourceType in
            SWImagePicker(sourceType: sourceType, allowsEditing: true) {
                newAvatarImageModel = .init(uiImage: $0)
                userForm.image = $0.toMediaFile()
            }
            .ignoresSafeArea()
        }
    }

    var genderPicker: some View {
        Menu {
            Picker("", selection: $userForm.genderCode) {
                ForEach([Gender.male, Gender.female], id: \.code) {
                    Text($0.affiliation)
                }
            }
        } label: {
            ListRowView(
                leadingContent: .iconWithText(
                    .personQuestion,
                    userForm.placeholder(.gender)
                ),
                trailingContent: .textWithChevron(userForm.genderString)
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
                selectedItem: userForm.country?.name,
                didSelectItem: { selectCountry(name: $0) },
                didTapContactUs: sendFeedback
            )
            .trackScreen(.countryList, source: .editProfile)
        } label: {
            ListRowView(
                leadingContent: .iconWithText(
                    .globe,
                    userForm.placeholder(.country)
                ),
                trailingContent: .textWithChevron(.init(userForm.selectedCountryName)),
                hint: userForm.countryHint
            )
        }
        .padding(.bottom, 6)
    }

    var cityPicker: some View {
        NavigationLink {
            ItemListScreen(
                mode: .city,
                allItems: locations.cities.map(\.name),
                selectedItem: userForm.city?.name,
                didSelectItem: { selectCity(name: $0) },
                didTapContactUs: sendFeedback
            )
            .trackScreen(.cityList, source: .editProfile)
        } label: {
            ListRowView(
                leadingContent: .iconWithText(
                    .signPost,
                    userForm.placeholder(.city)
                ),
                trailingContent: .textWithChevron(.init(userForm.selectedCityName)),
                hint: userForm.cityHint
            )
        }
        .onAppear {
            parksManager.setShowMissingAddressBadge(false)
        }
    }

    var saveChangesButton: some View {
        Button("Сохранить", action: saveChangesAction)
            .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
            .padding([.horizontal, .bottom])
            .disabled(!userForm.isReadyToSave(comparedTo: oldUserForm))
    }

    func prepareLocationsAndUserForm() {
        guard locations.isEmpty else { return }
        do {
            locations = try .init()
            if let userInfo = defaults.mainUserInfo {
                oldUserForm = .init(userInfo)
                oldUserForm.country = locations.countries
                    .first(where: { $0.id == oldUserForm.country?.id })
                oldUserForm.city = locations.cities
                    .first(where: { $0.id == oldUserForm.city?.id })
                userForm = oldUserForm
            }
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
        }
    }

    func selectCountry(name countryName: String, source: AnalyticsEvent.AppScreen = .editProfile) {
        let result = locations.selectCountry(name: countryName, city: userForm.city)
        userForm.country = result.newCountry
        userForm.city = result.newCity
        locations.cities = result.newCities
        if let country = result.newCountry {
            analytics.log(.userAction(action: .selectCountry(countryId: "\(country.id)", source: source)))
        }
    }

    func selectCity(name cityName: String) {
        let result = locations.selectCity(name: cityName, country: userForm.country)
        userForm.city = result.newCity
        if let city = result.newCity {
            analytics.log(.userAction(action: .selectCity(cityId: "\(city.id)", source: .editProfile)))
        }
        if let countryName = result.countryName {
            selectCountry(name: countryName, source: .editProfile)
        }
    }

    func saveChangesAction() {
        analytics.log(.userAction(action: .saveProfile))
        guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
        isLoading = true
        editUserTask = Task {
            do {
                #if DEBUG
                let client: ProfileClient = Constants.isUITest
                    ? MockSWClient(instantResponse: true)
                    : SWClient(with: defaults.authHelper)
                #else
                let client: ProfileClient = SWClient(with: defaults.authHelper)
                #endif
                let userId = defaults.mainUserInfo?.id ?? 0
                let result = try await client.editUser(userId, model: userForm)
                try Task.checkCancellation()
                try defaults.saveUserInfo(result)
                let password = try defaults.getUserPassword()
                defaults.saveAuthData(.init(login: userForm.userName, password: password))
                dismiss()
            } catch {
                analytics.log(.appError(kind: .profileSaveFailed, error: error))
                isLoading = false
                SWAlert.shared.presentDefaultUIKit(error)
            }
        }
    }

    func sendFeedback(mode: ItemListScreen.Mode) {
        let source = switch mode {
        case .city: AnalyticsEvent.AppScreen.cityList
        case .country: AnalyticsEvent.AppScreen.countryList
        }
        analytics.log(.userAction(action: .sendFeedback(source: source)))
        let (subject, body) = switch mode {
        case .city: (LocationFeedback.city.subject, LocationFeedback.city.body)
        case .country: (LocationFeedback.country.subject, LocationFeedback.country.body)
        }
        FeedbackSender.sendFeedback(
            subject: subject,
            messageBody: body,
            recipients: Constants.feedbackRecipient
        )
    }
}

private extension EditProfileLocations {
    /// Инициализирует модель данными из сохраненного `JSON`, если это возможно
    init() throws {
        let allCountries = try SWAddress.countries()
        self.init(countries: allCountries)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        let mockAuthHelper = MockAuthHelper()
        EditProfileScreen()
            .environmentObject(DefaultsService(authHelper: mockAuthHelper))
            .environmentObject(ParksManager(authHelper: mockAuthHelper))
    }
}
#endif
