//
//  City.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 02.05.2022.
//

import Foundation

struct City: Codable, Identifiable,Hashable {
    let id, name: String

    static var defaultCity: Self {
        .init(id: "1", name: "Москва")
    }
}
