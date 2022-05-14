//
//  SportsGroundsService.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 14.05.2022.
//

import Foundation

final class SportsGroundsService: ObservableObject {
    @Published var list = Bundle.main.decodeJson(
        [SportsGround].self,
        fileName: "areas.json"
    )
}
