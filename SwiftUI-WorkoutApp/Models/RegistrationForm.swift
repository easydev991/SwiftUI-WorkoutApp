//
//  RegistrationForm.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 14.05.2022.
//

import Foundation

struct RegistrationForm: Codable, Equatable {
    var userName, fullName, email, password, birthDate, countryID, cityID: String
    var gender: Int

    init(userName: String, fullName: String, email: String, password: String, birthDate: String, countryID: String, cityID: String, gender: Int) {
        self.userName = userName
        self.fullName = fullName
        self.email = email
        self.password = password
        self.birthDate = birthDate
        self.countryID = countryID
        self.cityID = cityID
        self.gender = gender
    }

    init(_ user: UserResponse) {
        self.userName = user.userName.valueOrEmpty
        self.fullName = user.fullName.valueOrEmpty
        self.email = user.email.valueOrEmpty
        self.password = ""
        self.birthDate = user.birthDateIsoString.valueOrEmpty
        self.countryID = user.countryID.valueOrZero.description
        self.cityID = user.cityID.valueOrZero.description
        self.gender = user.genderCode.valueOrZero
    }
}

extension RegistrationForm {
    static var emptyValue: Self {
        .init(userName: "", fullName: "", email: "", password: "", birthDate: "", countryID: "", cityID: "", gender: .zero)
    }

    /// Готова ли форма к отправке
    var isComplete: Bool {
        !userName.isEmpty
        && !email.isEmpty
        && password.count >= Constants.minPasswordSize
    }
}
