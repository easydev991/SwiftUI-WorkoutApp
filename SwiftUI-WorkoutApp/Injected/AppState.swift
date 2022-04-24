//
//  AppState.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import Foundation
import SwiftUI
import MapKit

final class AppState: ObservableObject {
    @AppStorage("isUserAuthorized") var isUserAuthorized = false
    @AppStorage("showWelcome") var showWelcome = true
    @Published var selectedTab = ContentView.Tab.events.rawValue
    @Published var countries = [CountryElement]()
    @Published var selectedCountry = CountryElement(
        cities: [], id: "", name: ""
    )
    @Published var selectedCity = City(id: "", name: "")
    @Published var cities = [City]()
    @Published var selectedGender = "Мужской"
    @Published var genders = ["Мужской", "Женский"]

    private let feedbackHelper: IFeedbackHelper
    fileprivate let locationManager = LocationManager()

    init() {
        feedbackHelper = FeedbackHelper()
        makeCountryAndCityData()
    }

    func selectTab(_ tab: ContentView.Tab) {
        selectedTab = tab.rawValue
        locationManager.setEnabled(tab == .map)
    }

    func selectCountry(_ country: CountryElement) {
        selectedCountry = country
        updateCityIfNeeded(for: country)
    }

    func selectCity(_ city: City) {
        selectedCity = city
    }

    var mapRegion: MKCoordinateRegion {
        get { locationManager.region }
        set { locationManager.region = newValue }
    }

    var mapAnnotations: [SportsGround] {
        get { locationManager.annotations }
        set { locationManager.annotations = newValue }
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

private extension AppState {
    final class LocationManager: NSObject, CLLocationManagerDelegate {
        private let manager = CLLocationManager()
        var region = MKCoordinateRegion()
        var annotations = Bundle.main.decodeJson(
            [SportsGround].self,
            fileName: "areas.json"
        )

        override init() {
            super.init()
            manager.delegate = self
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
        }

        func setEnabled(_ enabled: Bool) {
            if enabled {
                manager.startUpdatingLocation()
            } else {
                manager.stopUpdatingLocation()
            }
        }

        func locationManager(
            _ manager: CLLocationManager,
            didUpdateLocations locations: [CLLocation]
        ) {
            if let location = locations.last {
                region = .init(
                    center: location.coordinate,
                    span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        }

        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                manager.requestLocation()
            case .restricted:
                print("--- Restricted location")
            case .denied:
                print("--- Denied location")
            @unknown default: break
            }
        }

        func locationManager(
            _ manager: CLLocationManager,
            didFailWithError error: Error
        ) {
            print("--- LocationManager did fail with error: \(error.localizedDescription)")
        }
    }
}
