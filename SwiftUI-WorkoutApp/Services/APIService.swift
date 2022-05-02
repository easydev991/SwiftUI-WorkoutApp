//
//  APIService.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 01.05.2022.
//

import Foundation

struct APIService {
    static func configuredURLSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Constants.API.timeOut
        config.timeoutIntervalForResource = Constants.API.timeOut
        config.waitsForConnectivity = true
        return .init(configuration: config)
    }

    static func handleResponse<T: Decodable>(
        _ type: T.Type,
        data: Data?,
        response: URLResponse?
    ) throws -> T {
        let responseCode = (response as? HTTPURLResponse)?.statusCode
        if responseCode != 200, let error = APIError(with: responseCode) {
            throw error
        }
        guard let data = data, !data.isEmpty else {
            throw APIError.noData
        }
        print("--- Получили ответ:")
        dump(response)
        let prettyString = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\n", with: "")
        print("--- Полученный JSON:\n\(prettyString.valueOrEmpty)")
        do {
            let decodedInfo = try JSONDecoder().decode(type, from: data)
            print("--- Преобразованные данные:\n\(decodedInfo)")
            return decodedInfo
        } catch {
            throw error
        }
    }
}
