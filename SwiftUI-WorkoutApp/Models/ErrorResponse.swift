//
//  ErrorResponse.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 01.05.2022.
//

import Foundation

#warning("TODO: парсить при получении ошибок")
struct ErrorResponse: Codable {
    let name, message: String?
    let code, status: Int?
    let type: String?
}
