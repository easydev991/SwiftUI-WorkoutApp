//
//  RegistrationForm.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 14.05.2022.
//

import Foundation

struct RegistrationForm: Codable {
    var userName, fullName, email, password, birthDate, countryID, cityID: String
    var gender: Int

    static var emptyValue: Self {
        .init(userName: "", fullName: "", email: "", password: "", birthDate: "", countryID: "", cityID: "", gender: .zero)
    }

    var isComplete: Bool {
        !userName.isEmpty
        && !email.isEmpty
        && password.count >= Constants.minPasswordSize
    }
}
