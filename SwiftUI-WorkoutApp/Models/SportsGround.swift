import DateFormatterService
import Foundation
import MapKit.MKGeometry

/// Модель данных спортивной площадки
final class SportsGround: NSObject, Codable, MKAnnotation, Identifiable {
    let id, typeID, sizeID: Int
    let address: String?
    let author: UserResponse?
    let cityID, commentsCount, countryID: Int?
    let createDate, modifyDate: String?
    let latitude, longitude: String
    let name: String?
    var photosOptional: [Photo]?
    let preview: String?
    let usersTrainHereCount: Int?
    var usersTrainHereText: String {
        "Тренируется \(usersTrainHereCount.valueOrZero) чел."
    }

    var commentsOptional: [CommentResponse]?
    var usersTrainHere: [UserResponse]?
    var trainHereOptional: Bool?
    var title: String? { "Площадка № \(id)" }
    var subtitle: String? {
        let grade = SportsGroundGrade(id: typeID).rawValue
        let size = SportsGroundSize(id: sizeID).rawValue
        return grade + " / " + size
    }

    var shortTitle: String { "№ \(id)" }
    /// shortTitle + subtitle
    var longTitle: String {
        shortTitle + " " + subtitle.valueOrEmpty
    }

    var authorID: Int {
        (author?.userID).valueOrZero
    }

    var authorName: String {
        (author?.userName).valueOrEmpty
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
        case cityID = "city_id"
        case sizeID = "class_id"
        case commentsCount = "comments_count"
        case countryID = "country_id"
        case createDate = "create_date"
        case id, latitude, longitude, name, preview
        case usersTrainHereCount = "trainings"
        case commentsOptional = "comments"
        case photosOptional = "photos"
        case modifyDate = "modify_date"
        case typeID = "type_id"
        case trainHereOptional = "train_here"
        case usersTrainHere = "users_train_here"
    }

    init(
        id: Int,
        typeID: Int,
        sizeID: Int,
        address: String?,
        author: UserResponse?,
        cityID: Int?,
        commentsCount: Int?,
        countryID: Int?,
        createDate: String?,
        modifyDate: String?,
        latitude: String,
        longitude: String,
        name: String?,
        photosOptional: [Photo]?,
        preview: String?,
        usersTrainHereCount: Int?,
        commentsOptional: [CommentResponse]?,
        usersTrainHere: [UserResponse]?,
        trainHere: Bool?
    ) {
        self.id = id
        self.typeID = typeID
        self.sizeID = sizeID
        self.address = address
        self.author = author
        self.cityID = cityID
        self.commentsCount = commentsCount
        self.countryID = countryID
        self.createDate = createDate
        self.modifyDate = modifyDate
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.photosOptional = photosOptional
        self.preview = preview
        self.usersTrainHereCount = usersTrainHereCount
        self.commentsOptional = commentsOptional
        self.usersTrainHere = usersTrainHere
        self.trainHereOptional = trainHere
    }

    convenience init(id: Int) {
        self.init(
            id: id,
            typeID: .zero,
            sizeID: .zero,
            address: nil,
            author: nil,
            cityID: nil,
            commentsCount: nil,
            countryID: nil,
            createDate: nil,
            modifyDate: nil,
            latitude: "",
            longitude: "",
            name: nil,
            photosOptional: nil,
            preview: nil,
            usersTrainHereCount: nil,
            commentsOptional: nil,
            usersTrainHere: nil,
            trainHere: nil
        )
    }
}

struct Photo: Codable, Identifiable, Equatable {
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

struct CommentResponse: Codable, Identifiable, Hashable {
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
        DateFormatterService.readableDate(from: date)
    }
}

extension SportsGround {
    var photos: [Photo] {
        get { photosOptional ?? [] }
        set { photosOptional = newValue }
    }

    var comments: [CommentResponse] {
        get { commentsOptional ?? [] }
        set { commentsOptional = newValue }
    }

    /// Пользователи, которые тренируются на этой площадке
    var participants: [UserResponse] {
        get { usersTrainHere ?? [] }
        set { usersTrainHere = newValue }
    }

    /// Пользователь тренируется на этой площадке
    var trainHere: Bool {
        get { trainHereOptional.isTrue }
        set { trainHereOptional = newValue }
    }

    /// `true` - сервер прислал всю информацию о площадке, `false` - не всю
    var isFull: Bool {
        usersTrainHereCount.valueOrZero > .zero && !participants.isEmpty
            || commentsCount.valueOrZero > .zero && !comments.isEmpty
    }

    static var emptyValue: SportsGround {
        .init(
            id: .zero,
            typeID: .zero,
            sizeID: .zero,
            address: nil,
            author: .emptyValue,
            cityID: nil,
            commentsCount: nil,
            countryID: nil,
            createDate: nil,
            modifyDate: nil,
            latitude: "",
            longitude: "",
            name: nil,
            photosOptional: [],
            preview: nil,
            usersTrainHereCount: .zero,
            commentsOptional: nil,
            usersTrainHere: [],
            trainHere: nil
        )
    }
}
