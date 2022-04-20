//
//  SportsGround.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import Foundation
import CoreLocation

struct SportsGround: Codable, Identifiable {
    let address: String
    let author: Author
    let canEdit: Bool
    let cityID, classID, commentsCount, countryID: Int
    let createDate: String?
    let equipmentIDS: [Int]
    let id: Int
    let latitude, longitude: String
    let mine: Bool
    let modifyDate: String?
    let name: String
    let photos: [Photo]
    let preview: String
    let trainings: Trainings
    let typeID: Int
    var coordinate: CLLocationCoordinate2D {
        .init(
            latitude: .init(Double(latitude) ?? .zero),
            longitude: .init(Double(longitude) ?? .zero)
        )
    }

    enum CodingKeys: String, CodingKey {
        case address, author
        case canEdit = "can_edit"
        case cityID = "city_id"
        case classID = "class_id"
        case commentsCount = "comments_count"
        case countryID = "country_id"
        case createDate = "create_date"
        case equipmentIDS = "equipment_ids"
        case id, latitude, longitude, mine, name, photos, preview, trainings
        case modifyDate = "modify_date"
        case typeID = "type_id"
    }
}

struct Author: Codable {
    let id: Int
    let image: String
    let name: String
}

struct Photo: Codable {
    let id: Int
    let photo: String
}

enum Trainings: Codable {
    case integer(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(
            Trainings.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Wrong type for Trainings"
            )
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}
