//
//  AppState.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import Foundation
import SwiftUI
import MapKit.MKGeometry

final class AppState: ObservableObject {
    @AppStorage("isUserAuthorized") var isUserAuthorized = false
    @AppStorage("showWelcome") var showWelcome = true
    @Published var selectedTab = ContentView.Tab.events
    @Published var countries = [CountryElement]()
    @Published var selectedCountry = CountryElement(
        cities: [], id: "", name: ""
    )
    @Published var selectedCity = City(id: "", name: "")
    @Published var cities = [City]()
    @Published var selectedGender = "Мужской"
    @Published var genders = ["Мужской", "Женский"]

    private let feedbackHelper: IFeedbackHelper
    private let locationService: LocationService

    init() {
        feedbackHelper = FeedbackHelper()
        locationService = LocationService()
        makeCountryAndCityData()
    }

    func selectTab(_ tab: ContentView.Tab) {
        selectedTab = tab
        locationService.setEnabled(tab == .map)
    }

    func selectCountry(_ country: CountryElement) {
        selectedCountry = country
        updateCityIfNeeded(for: country)
    }

    func selectCity(_ city: City) {
        selectedCity = city
    }

    var mapRegion: MKCoordinateRegion {
        get { locationService.region }
        set { locationService.region = newValue }
    }

    var mapAnnotations: [SportsGround] {
        get { locationService.annotations }
        set { locationService.annotations = newValue }
    }

    func sendFeedback() {
        feedbackHelper.sendFeedback()
    }
}

private extension AppState {
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
