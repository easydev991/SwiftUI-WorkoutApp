//
//  EditAccountViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import Foundation

final class EditAccountViewModel: ObservableObject {
    @Published var countries = [Country]()
    @Published var selectedCountry = Country(
        cities: [], id: "", name: ""
    )
    @Published var selectedCity = City(id: "", name: "")
    @Published var cities = [City]()
    @Published var selectedGender = ""
    @Published var genders = Constants.Gender.allCases.map(\.rawValue)

    @Published var loginText = ""
    @Published var emailText = ""
    @Published var passwordText = ""
    @Published var nameText = ""
    @Published var birthDate = Date()
    var maxDate: Date {
        Calendar.current.date(
            byAdding: .year,
            value: Constants.minimumUserAge,
            to: .now
        ) ?? .now
    }

#warning("TODO: интеграция с сервером")
#warning("TODO: интеграция с БД")
    /// Доступность кнопки для регистрации или сохранения изменений
    func isButtonAvailable(_ isUserAuth: Bool) -> Bool {
        if isUserAuth {
            return !loginText.isEmpty
            && !emailText.isEmpty
            && passwordText.count >= Constants.minPasswordSize
        } else {
            return false // убрать хардкод после интеграции с БД
        }
    }

    func title(_ isUserAuth: Bool) -> String {
        isUserAuth ? "Изменить профиль" : "Регистрация"
    }

    init() {
        makeCountryAndCityData()
    }

    deinit {
        print("--- deinited EditAccountViewModel")
    }

    func selectCountry(_ country: Country) {
        selectedCountry = country
        updateCityIfNeeded(for: country)
    }

    func selectCity(_ city: City) {
        selectedCity = city
    }

    func registerAction() {
#warning("TODO: интеграция с сервером")
#warning("TODO: Проверить введенные данные")
        print("--- Проверяем введенные данные и начинаем регистрацию")
    }

    func saveChangesAction() {
#warning("TODO: интеграция с сервером")
#warning("TODO: интеграция с БД")
        print("--- сохраняем изменения в профиле")
    }
}

private extension EditAccountViewModel {
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
