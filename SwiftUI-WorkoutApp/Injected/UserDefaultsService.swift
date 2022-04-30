//
//  UserDefaultsService.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import SwiftUI

struct UserDefaultsService {
    @AppStorage("isUserAuthorized") var isUserAuthorized = false
    @AppStorage("showWelcome") var showWelcome = true
}
