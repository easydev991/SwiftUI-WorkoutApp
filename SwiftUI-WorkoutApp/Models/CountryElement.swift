//
//  CitiesResponse.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 17.04.2022.
//

import Foundation

struct CountryElement: Codable, Hashable {
    let cities: [City]
    var id, name: String
}

struct City: Codable, Hashable {
    let id, name: String
}
