//
//  EditUserInfoService.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import Foundation
import Combine

final class EditUserInfoService: ObservableObject {
    private let userDefaults = UserDefaultsService()
    @Published var countries = [CountryElement]()
    @Published var selectedCountry = CountryElement(
        cities: [], id: "", name: ""
    )
    @Published var selectedCity = City(id: "", name: "")
    @Published var cities = [City]()
    @Published var selectedGender = ""
    @Published var genders = ["Мужской", "Женский"]

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
    var isUserAuth: Bool {
        userDefaults.isUserAuthorized
    }
    var canRegister: Bool {
        !loginText.isEmpty && !emailText.isEmpty && passwordText.count >= 6
    }
    var title: String {
        isUserAuth ? "Изменить профиль" : "Регистрация"
    }

    init() {
        makeCountryAndCityData()
    }

    func selectCountry(_ country: CountryElement) {
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

private extension EditUserInfoService {
    func makeCountryAndCityData() {
        let _countries = Bundle.main.decodeJson(
            [CountryElement].self,
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

    func updateCityIfNeeded(for country: CountryElement) {
        if !country.cities.contains(where: { $0 == selectedCity }),
           let firstCity = country.cities.first {
            selectedCity = firstCity
            cities = country.cities
        }
    }
}
