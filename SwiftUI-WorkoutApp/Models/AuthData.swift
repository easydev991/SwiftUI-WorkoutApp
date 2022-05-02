//
//  AuthData.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 02.05.2022.
//

import Foundation

struct AuthData: Codable {
    let login, password: String

    var base64Encoded: String? {
        (login + ":" + password).data(using: .utf8)?.base64EncodedString()
    }

    static var emptyValue: Self {
        .init(login: "", password: "")
    }
}
