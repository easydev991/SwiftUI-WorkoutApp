import Foundation
import SWModels

@MainActor
final class EditAccountViewModel: ObservableObject {
    @Published var userForm = MainUserForm.emptyValue
    @Published var countries = [Country]()
    @Published var cities = [City]()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var isProfileSaved = false
    /// Ранее сохраненная форма с данными пользователя
    private var savedUserForm = MainUserForm.emptyValue
    var currentGender: Gender { .init(userForm.genderCode) ?? .unspecified }

    /// Доступность кнопки для сохранения изменений
    var canSaveChanges: Bool {
        userForm != savedUserForm && userForm.isReadyToSave
    }

    init() { makeCountryAndCityData() }

    func updateForm(with defaults: DefaultsProtocol) {
        guard userForm.userName.isEmpty else { return }
        if let userInfo = defaults.mainUserInfo {
            userForm = .init(userInfo)
            userForm.country = countries.first(where: { $0.id == userForm.country.id }) ?? .defaultCountry
            userForm.city = cities.first(where: { $0.id == userForm.city.id }) ?? .defaultCity
            savedUserForm = userForm
        }
    }

    func selectCountry(name countryName: String) {
        let newCountry = countries.first(where: { $0.name == countryName }) ?? .defaultCountry
        userForm.country = newCountry
        updateCityIfNeeded(for: newCountry)
    }

    func selectCity(name cityName: String) {
        userForm.city = cities.first(where: { $0.name == cityName }) ?? .defaultCity
    }

    func saveChangesAction(with defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            let userID = (defaults.mainUserInfo?.userID).valueOrZero
            isProfileSaved = try await APIService(with: defaults).editUser(userID, model: userForm)
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

private extension EditAccountViewModel {
    func makeCountryAndCityData() {
        do {
            let allCountries = try Bundle.main.decodeJson(
                [Country].self,
                fileName: "countries",
                extension: "json"
            )
            if let russia = allCountries.first(where: { $0.name == "Россия" }),
               let moscow = russia.cities.first(where: { $0.name == "Москва" }) {
                countries = allCountries.sorted { $0.name < $1.name }
                userForm.country = russia
                cities = russia.cities.sorted { $0.name < $1.name }
                userForm.city = moscow
            } else {
                #if DEBUG
                print("--- Россия и Москва должны быть в файле countries.json")
                #endif
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
    }

    func updateCityIfNeeded(for country: Country) {
        if !country.cities.contains(where: { $0 == userForm.city }),
           let firstCity = country.cities.first {
            userForm.city = firstCity
            cities = country.cities
        }
    }
}
