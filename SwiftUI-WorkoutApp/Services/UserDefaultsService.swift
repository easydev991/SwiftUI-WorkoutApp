//
//  UserDefaultsService.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import SwiftUI

final class UserDefaultsService: ObservableObject {
    @AppStorage("isUserAuthorized") var isUserAuthorized = false
    @AppStorage("showWelcome") var showWelcome = true
}
