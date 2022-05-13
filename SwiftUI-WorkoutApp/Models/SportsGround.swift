//
//  SportsGround.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import Foundation
import MapKit.MKGeometry

final class SportsGround: NSObject, Codable, MKAnnotation, Identifiable {
    let address: String?
    let author: UserResponse
    let canEdit: Bool
    let cityID, sizeID, commentsCount, countryID: Int?
    let createDate: String?
    let equipmentIDS: [Int]
    let id: Int
    let latitude, longitude: String
    let mine: Bool
    let modifyDate: String?
    let name: String?
    let photos: [Photo]
    let preview: String?
    let trainings: Trainings
    let typeID: Int
    let comments: [Comment]?
    let usersTrainHere: [UserResponse]?
    var title: String? { "Площадка № \(id)" }
    var subtitle: String? {
        let grade = SportsGroundGrade(id: typeID).grade.rawValue
        let size = SportsGroundSize(id: sizeID.valueOrZero).size.rawValue
        return grade + " / " + size
    }
    var shortTitle: String { "№ \(id)" }
    var peopleTrainHereCount: Int {
        switch trainings {
        case let .integer(int):
            return int
        case let .string(str):
            return Int(str).valueOrZero
        }
    }
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
        case id, latitude, longitude, mine, name, photos, preview, trainings, comments
        case modifyDate = "modify_date"
        case typeID = "type_id"
        case usersTrainHere = "users_train_here"
    }

    init(address: String?, author: UserResponse, canEdit: Bool, cityID: Int?, sizeID: Int?, commentsCount: Int?, countryID: Int?, createDate: String?, equipmentIDS: [Int], id: Int, latitude: String, longitude: String, mine: Bool, modifyDate: String?, name: String?, photos: [Photo], preview: String?, trainings: Trainings, typeID: Int, comments: [Comment]?, usersTrainHere: [UserResponse]?) {
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
        self.comments = comments
        self.usersTrainHere = usersTrainHere
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

enum Trainings: Codable, CustomStringConvertible {
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

    var description: String {
        let prefix = "Тренируется: "
        switch self {
        case let .integer(count):
            return prefix + "\(count) чел."
        case let .string(count):
            return prefix + count + " чел."
        }
    }
}

struct Comment: Codable, Identifiable {
    let id: Int
    let body, date: String?
    let user: UserResponse?

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
        .init(address: "", author: .emptyValue, canEdit: false, cityID: .zero, sizeID: .zero, commentsCount: .zero, countryID: .zero, createDate: nil, equipmentIDS: [], id: .zero, latitude: "", longitude: "", mine: false, modifyDate: nil, name: "", photos: [], preview: "", trainings: .integer(.zero), typeID: .zero, comments: nil, usersTrainHere: nil)
    }

    static let mock = SportsGround(
        address: "ул. Шоссе Нефтянников 11/1",
        author: .emptyValue,
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
                stringURL: "https://workout.su/uploads/userfiles/2017/10/2017-10-01-22-10-40-ohf.jpg"
            ),
            .init(
                id: 5,
                stringURL: "https://workout.su/uploads/userfiles/2017/10/2017-10-01-22-10-46-tgp.jpg"
            ),
            .init(
                id: 6,
                stringURL: "https://workout.su/uploads/userfiles/62D5DC6C-2E66-471B-B996-B9DD71688BE4.jpg"
            )
        ],
        preview: "https://workout.su/uploads/userfiles/2016/10/2016-10-14-15-10-13-qwt.jpg",
        trainings: .string("1"),
        typeID: 1,
        comments: [
            .init(
                id: 35,
                body: "на сколько я понял это \"крылья советов\" в принципе неплохой стадион но достаточно далеко до метро так что заниматься могут только люди которые живут в районе)",
                date: "2011-07-13T18:59:23+00:00",
                user: .init(userName: "rastoaman", fullName: nil, email: nil, imageStringURL: "https://workout.su/uploads/avatars/ad8c7eb668c2412954d11668f473a4a8dd4458bc.jpg", birthDateIsoString: nil, createdIsoDateTimeSec: nil, userID: 1317, cityID: nil, countryID: nil, genderCode: nil, friendsCount: nil, journalsCount: nil, friendRequestsCountString: nil, sportsGroundsCountString: nil, purchaseCustomerEditor: nil, lang: nil, rating: nil)
            ),
            .init(
                id: 69,
                body: "Да, это на стадионе \"Крылья Советов\".",
                date: "2011-09-29T19:18:07+00:00",
                user: .init(userName: "WasD", fullName: nil, email: nil, imageStringURL: "https://workout.su/uploads/avatars/2019/03/2019-03-21-23-03-49-rjk.jpg", birthDateIsoString: nil, createdIsoDateTimeSec: nil, userID: 30, cityID: nil, countryID: nil, genderCode: nil, friendsCount: nil, journalsCount: nil, friendRequestsCountString: nil, sportsGroundsCountString: nil, purchaseCustomerEditor: nil, lang: nil, rating: nil)
            ),
            .init(
                id: 70,
                body: "100% \"Крылья\" !!  Бываю там частенько )))",
                date: "2011-09-30T11:03:44+00:00",
                user: .init(userName: "JA666", fullName: nil, email: nil, imageStringURL: "https://workout.su/img/avatar_default.jpg", birthDateIsoString: nil, createdIsoDateTimeSec: nil, userID: 2301, cityID: nil, countryID: nil, genderCode: nil, friendsCount: nil, journalsCount: nil, friendRequestsCountString: nil, sportsGroundsCountString: nil, purchaseCustomerEditor: nil, lang: nil, rating: nil)
            )
        ],
        usersTrainHere: [
            .init(userName: "ninenineone", fullName: nil, email: nil, imageStringURL: "https://workout.su/uploads/avatars/2018/01/2018-01-28-13-01-38-asm.jpg", birthDateIsoString: nil, createdIsoDateTimeSec: nil, userID: 10367, cityID: 1, countryID: 17, genderCode: nil, friendsCount: nil, journalsCount: nil, friendRequestsCountString: nil, sportsGroundsCountString: nil, purchaseCustomerEditor: false, lang: "ru", rating: nil)
        ]
    )
}
