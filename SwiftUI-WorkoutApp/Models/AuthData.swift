//
//  AuthData.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 02.05.2022.
//

import Foundation

struct AuthData {
    let login, password: String

    var base64Encoded: String? {
        (login + ":" + password).data(using: .utf8)?.base64EncodedString()
    }
}
