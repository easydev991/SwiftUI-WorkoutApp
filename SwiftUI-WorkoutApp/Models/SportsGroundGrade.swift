//
//  SportsGroundGrade.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 22.04.2022.
//

import Foundation

struct SportsGroundGrade {
    let grade: Grade

    enum Grade: String {
        case soviet = "Советская"
        case modern = "Современная"
        case collars = "Хомуты"
        case underTheHood = "Под навесом"
        case legendary = "Легендарная"
    }

    init(id: Int) {
        switch id {
        case 1:
            grade = .soviet
        case 2:
            grade = .modern
        case 3:
            grade = .collars
        case 4:
            grade = .underTheHood
        default:
            grade = .legendary // id = 6
        }
    }
}
