//
//  EditAccountViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import Foundation

final class EditAccountViewModel: ObservableObject {
    @Published var regForm = RegistrationForm.emptyValue
    @Published var countries = [Country]()
    @Published var selectedCountry = Country.defaultCountry {
        didSet { regForm.countryID = selectedCountry.id }
    }
    @Published var selectedCity = City.defaultCity {
        didSet { regForm.cityID = selectedCity.id }
    }
    @Published var cities = [City]()
    @Published var birthDate = Constants.defaultUserAge {
        didSet { updateBirthDate() }
    }
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
#warning("TODO: интеграция с сервером")
#warning("TODO: интеграция с БД")
    /// Доступность кнопки для регистрации или сохранения изменений
    func isButtonAvailable(_ isUserAuth: Bool) -> Bool {
        if isUserAuth {
            return false // убрать хардкод после интеграции с БД
        } else {
            return regForm.isComplete
        }
    }

    func title(_ isUserAuth: Bool) -> String {
        isUserAuth ? "Изменить профиль" : "Регистрация"
    }

    init() {
        makeCountryAndCityData()
    }

    func selectCountry(_ country: Country) {
        selectedCountry = country
        updateCityIfNeeded(for: country)
    }

    func selectCity(_ city: City) {
        selectedCity = city
    }

    @MainActor
    func registerAction(with defaults: UserDefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            try await APIService(with: defaults).completeRegistration(with: regForm)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func saveChangesAction() {
#warning("TODO: интеграция с сервером")
#warning("TODO: интеграция с БД")
    }

    func clearErrorMessage() {
        errorMessage = ""
    }
}

private extension EditAccountViewModel {
    func updateBirthDate() {
        regForm.birthDate = FormatterService.isoStringFromDate(date: birthDate)
    }

    func makeCountryAndCityData() {
        let _countries = Bundle.main.decodeJson(
            [Country].self,
            fileName: "countries.json"
        )
        guard let russia = _countries.first(where: { $0.name == "Россия" }),
              let moscow = russia.cities.first(where: { $0.name == "Москва" }) else {
            fatalError("Россия и Москва должны быть в файле countries.json")
        }
        countries = _countries.sorted { $0.name < $1.name }
        selectedCountry = russia
        cities = russia.cities.sorted { $0.name < $1.name }
        selectedCity = moscow
    }

    func updateCityIfNeeded(for country: Country) {
        if !country.cities.contains(where: { $0 == selectedCity }),
           let firstCity = country.cities.first {
            selectedCity = firstCity
            cities = country.cities
        }
    }
}
