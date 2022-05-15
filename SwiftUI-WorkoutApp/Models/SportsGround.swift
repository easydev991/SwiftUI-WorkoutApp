//
//  SportsGround.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import Foundation
import MapKit.MKGeometry

/// Модель данных спортивной площадки
final class SportsGround: NSObject, Codable, MKAnnotation, Identifiable {
    let id, typeID: Int
    let address: String?
    let author: UserResponse
    let canEdit, mine: Bool
    let cityID, sizeID, commentsCount, countryID: Int?
    let createDate, modifyDate: String?
    let equipmentIDS: [Int]
    let latitude, longitude: String
    let name: String?
    let photos: [Photo]
    let preview: String?
    let usersTrainHereCount: Int?
    var commentsOptional: [Comment]?
    var comments: [Comment] {
        get { commentsOptional ?? [] }
        set { commentsOptional = newValue }
    }
    /// Пользователи, которые тренируются на этой площадке
    var usersTrainHere: [UserResponse]?
    var participants: [UserResponse] {
        get { usersTrainHere ?? [] }
        set { usersTrainHere = newValue }
    }
    var trainHereOptional: Bool?
    /// Пользователь тренируется на этой площадке
    var trainHere: Bool {
        get { trainHereOptional.isTrue }
        set { trainHereOptional = newValue }
    }
    var title: String? { "Площадка № \(id)" }
    var subtitle: String? {
        let grade = SportsGroundGrade(id: typeID).grade.rawValue
        let size = SportsGroundSize(id: sizeID.valueOrZero).size.rawValue
        return grade + " / " + size
    }
    var shortTitle: String { "№ \(id)" }
    var coordinate: CLLocationCoordinate2D {
        .init(
            latitude: .init(Double(latitude) ?? .zero),
            longitude: .init(Double(longitude) ?? .zero)
        )
    }
    private let regionRadius: CLLocationDistance = 1000
    var region: MKCoordinateRegion {
        .init(
            center: coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
    }
    var appleMapsURL: URL? {
        .init(string: "maps://?saddr=&daddr=\(coordinate.latitude),\(coordinate.longitude)")
    }
    var previewImageURL: URL? {
        .init(string: preview.valueOrEmpty)
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
        case id, latitude, longitude, mine, name, photos, preview
        case usersTrainHereCount = "trainings"
        case commentsOptional = "comments"
        case modifyDate = "modify_date"
        case typeID = "type_id"
        case trainHereOptional = "train_here"
        case usersTrainHere = "users_train_here"
    }

    init(id: Int, typeID: Int, address: String?, author: UserResponse, canEdit: Bool, mine: Bool, cityID: Int?, sizeID: Int?, commentsCount: Int?, countryID: Int?, createDate: String?, modifyDate: String?, equipmentIDS: [Int], latitude: String, longitude: String, name: String?, photos: [Photo], preview: String?, usersTrainHereCount: Int?, commentsOptional: [Comment]?, usersTrainHere: [UserResponse]?, trainHere: Bool?) {
        self.id = id
        self.typeID = typeID
        self.address = address
        self.author = author
        self.canEdit = canEdit
        self.mine = mine
        self.cityID = cityID
        self.sizeID = sizeID
        self.commentsCount = commentsCount
        self.countryID = countryID
        self.createDate = createDate
        self.modifyDate = modifyDate
        self.equipmentIDS = equipmentIDS
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.photos = photos
        self.preview = preview
        self.usersTrainHereCount = usersTrainHereCount
        self.commentsOptional = commentsOptional
        self.usersTrainHere = usersTrainHere
        self.trainHereOptional = trainHere
    }
}

struct Photo: Codable, Identifiable {
    let id: Int
    let stringURL: String?

    var imageURL: URL? {
        .init(string: stringURL.valueOrEmpty)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case stringURL = "photo"
    }
}

struct Comment: Codable, Identifiable, Hashable {
    let id: Int
    let body, date: String?
    let user: UserResponse?

    var formattedBody: String {
        body.valueOrEmpty.withoutHTML.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    enum CodingKeys: String, CodingKey {
        case id = "comment_id"
        case body, date, user
    }

    var formattedDateString: String {
        FormatterService.readableDate(from: date)
    }
}

extension SportsGround {
    static var emptyValue: SportsGround {
        .init(id: .zero, typeID: .zero, address: nil, author: .emptyValue, canEdit: false, mine: false, cityID: nil, sizeID: nil, commentsCount: nil, countryID: nil, createDate: nil, modifyDate: nil, equipmentIDS: [], latitude: "", longitude: "", name: nil, photos: [], preview: nil, usersTrainHereCount: .zero, commentsOptional: nil, usersTrainHere: [], trainHere: nil)
    }
}
