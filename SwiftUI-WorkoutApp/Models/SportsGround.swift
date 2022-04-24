//
//  SportsGround.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import Foundation
import CoreLocation
import MapKit.MKGeometry

final class SportsGround: NSObject, Codable, MKAnnotation, Identifiable {
    let address: String
    let author: Author
    let canEdit: Bool
    let cityID, sizeID, commentsCount, countryID: Int
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
    var title: String? {
        "Площадка № \(id)"
    }
    var subtitle: String? {
        let grade = SportsGroundGrade(id: typeID).grade.rawValue
        let size = SportsGroundSize(id: sizeID).size.rawValue
        return grade + " / " + size
    }
    var shortTitle: String {
        "№ \(id)"
    }
    var peopleTrainHereCount: Int {
        switch trainings {
        case let .integer(int):
            return int
        case let .string(str):
            return Int(str) ?? .zero
        }
    }
    private let regionRadius: CLLocationDistance = 1000
    var coordinate: CLLocationCoordinate2D {
        .init(
            latitude: .init(Double(latitude) ?? .zero),
            longitude: .init(Double(longitude) ?? .zero)
        )
    }
    var region: MKCoordinateRegion {
        .init(
            center: coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
    }

    enum CodingKeys: String, CodingKey {
        case address, author
        case canEdit = "can_edit"
        case cityID = "city_id"
        case sizeID = "class_id"
        case commentsCount = "comments_count"
        case countryID = "country_id"
        case createDate = "create_date"
        case equipmentIDS = "equipment_ids"
        case id, latitude, longitude, mine, name, photos, preview, trainings
        case modifyDate = "modify_date"
        case typeID = "type_id"
    }

    init(address: String, author: Author, canEdit: Bool, cityID: Int, sizeID: Int, commentsCount: Int, countryID: Int, createDate: String?, equipmentIDS: [Int], id: Int, latitude: String, longitude: String, mine: Bool, modifyDate: String?, name: String, photos: [Photo], preview: String, trainings: Trainings, typeID: Int) {
        self.address = address
        self.author = author
        self.canEdit = canEdit
        self.cityID = cityID
        self.sizeID = sizeID
        self.commentsCount = commentsCount
        self.countryID = countryID
        self.createDate = createDate
        self.equipmentIDS = equipmentIDS
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.mine = mine
        self.modifyDate = modifyDate
        self.name = name
        self.photos = photos
        self.preview = preview
        self.trainings = trainings
        self.typeID = typeID
    }
}

struct Author: Codable, Identifiable {
    let id: Int
    let imageStringURL: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case imageStringURL = "image"
    }
}

struct Photo: Codable, Identifiable {
    let id: Int
    let stringURL: String

    enum CodingKeys: String, CodingKey {
        case id
        case stringURL = "photo"
    }
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
        case let .integer(int):
            try container.encode(int)
        case let .string(str):
            try container.encode(str)
        }
    }
}

extension SportsGround {
    static let mock = SportsGround(
        address: "ул. Шоссе Нефтянников 11/1",
        author: .init(
            id: 22377,
            imageStringURL: "https://workout.su/uploads/avatars/1442580670.jpg",
            name: "Albert_88"
        ),
        canEdit: false,
        cityID: 67,
        sizeID: 1,
        commentsCount: .zero,
        countryID: 17,
        createDate: "2016-10-14T15:13:25+03:00",
        equipmentIDS: [3, 5, 6, 8, 21],
        id: 5828,
        latitude: "45.058418265072795",
        longitude: "38.98097947239876",
        mine: false,
        modifyDate: "2017-12-28T23:45:54+03:00",
        name: "№5828 Маленькая Советская",
        photos: [
            .init(
                id: 1,
                stringURL: "https://workout.su/uploads/userfiles/2017/09/2017-09-18-12-09-22-gmw.jpg"
            ),
            .init(
                id: 2,
                stringURL: "https://workout.su/uploads/userfiles/2017/09/2017-09-18-12-09-38-px8.jpg"
            ),
            .init(
                id: 3,
                stringURL: "https://workout.su/uploads/userfiles/2017/09/2017-09-18-12-09-51-4e4.jpg"
            ),
            .init(
                id: 4,
                stringURL: "https://workout.su/uploads/userfiles/2017/09/2017-09-18-12-09-22-gmw.jpg"
            ),
            .init(
                id: 5,
                stringURL: "https://workout.su/uploads/userfiles/2017/09/2017-09-18-12-09-38-px8.jpg"
            ),
            .init(
                id: 6,
                stringURL: "https://workout.su/uploads/userfiles/2017/09/2017-09-18-12-09-51-4e4.jpg"
            )
        ],
        preview: "https://workout.su/uploads/userfiles/2016/10/2016-10-14-15-10-13-qwt.jpg",
        trainings: .string("1"),
        typeID: 1
    )
}
