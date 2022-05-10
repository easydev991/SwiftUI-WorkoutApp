//
//  ShortAddressService.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 03.05.2022.
//

import Foundation

struct ShortAddressService {
    private let countries = Bundle.main.decodeJson(
        [Country].self,
        fileName: "countries.json"
    )

    func addressFor(_ countryID: Int, _ cityID: Int) -> String {
        let country = countries.first(where: { $0.id == String(countryID) })
        let city = country?.cities.first(where: { $0.id == String(cityID) })
        let countryName = (country?.name).valueOrEmpty
        if let cityName = city?.name {
            return countryName + ", " + cityName
        } else {
            return countryName
        }
    }
}
