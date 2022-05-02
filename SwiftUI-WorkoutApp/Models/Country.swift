//
//  Country.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 17.04.2022.
//

import Foundation

struct Country: Codable, Hashable {
    let cities: [City]
    var id, name: String
}
