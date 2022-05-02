//
//  LoginService.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 01.05.2022.
//

import Foundation

struct LoginService {
    private let defaults: UserDefaultsService
    private let authData: AuthData

    init(
        _ defaults: UserDefaultsService,
        _ login: String,
        _ password: String
    ) {
        self.defaults = defaults
        self.authData = .init(login: login, password: password)
    }

    func loginRequest() async throws {
        let endpoint = Endpoint.login(auth: authData)
        guard let request = endpoint.urlRequest else { return }
        do {
            let (data, response) = try await APIService.configuredURLSession().data(for: request)
            let loginResponse = try APIService.handleResponse(LoginResponse.self, data: data, response: response)
            try await userRequest(with: loginResponse.userID)
        } catch {
            throw error
        }
    }

    private func userRequest(with userID: Int) async throws {
        let endpoint = Endpoint.getUser(id: userID, auth: authData)
        guard let request = endpoint.urlRequest else { return }
        do {
            let (data, response) = try await APIService.configuredURLSession().data(for: request)
#warning("TODO: интеграция с БД - сохранить данные пользователя")
            _ = try APIService.handleResponse(UserResponse.self, data: data, response: response)
            await MainActor.run {
                defaults.isUserAuthorized = true
                defaults.showWelcome = false
            }
        } catch {
            throw error
        }
    }
}
