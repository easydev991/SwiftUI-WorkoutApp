//
//  Country.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 17.04.2022.
//

import Foundation

struct Country: Codable, Identifiable, Hashable {
    let cities: [City]
    var id, name: String

    static var defaultCountry: Self {
        .init(cities: [], id: "17", name: "Россия")
    }
}
