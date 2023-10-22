import DateFormatterService
import Foundation
import MapKit.MKGeometry

/// Модель данных спортивной площадки
public final class SportsGround: NSObject, Codable, MKAnnotation, Identifiable {
    public let id, typeID, sizeID: Int
    public let address: String?
    public let author: UserResponse?
    public let cityID, commentsCount, countryID: Int?
    public let createDate, modifyDate: String?
    public let latitude, longitude: String
    public let name: String?
    public var photosOptional: [Photo]?
    public let preview: String?
    public let usersTrainHereCount: Int?
    public var usersTrainHereText: String {
        String.localizedStringWithFormat(
            NSLocalizedString("peopleTrainHere", comment: ""),
            usersTrainHereCount.valueOrZero
        )
    }

    public var commentsOptional: [CommentResponse]?
    public var usersTrainHere: [UserResponse]?
    public var trainHereOptional: Bool?
    public var title: String? { "Площадка № \(id)" }
    public var subtitle: String? {
        let grade = NSLocalizedString(SportsGroundGrade(id: typeID).rawValue, comment: "")
        let size = NSLocalizedString(SportsGroundSize(id: sizeID).rawValue, comment: "")
        return grade + " / " + size
    }

    public var shortTitle: String { "№ \(id)" }
    /// shortTitle + subtitle
    public var longTitle: String {
        shortTitle + " " + subtitle.valueOrEmpty
    }

    public var authorID: Int {
        (author?.userID).valueOrZero
    }

    public var authorName: String {
        (author?.userName).valueOrEmpty
    }

    public var coordinate: CLLocationCoordinate2D {
        .init(
            latitude: .init(Double(latitude) ?? .zero),
            longitude: .init(Double(longitude) ?? .zero)
        )
    }

    private let regionRadius: CLLocationDistance = 1000
    public var region: MKCoordinateRegion {
        .init(
            center: coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
    }

    public var appleMapsURL: URL? {
        .init(string: "maps://?saddr=&daddr=\(coordinate.latitude),\(coordinate.longitude)")
    }

    public var previewImageURL: URL? {
        preview.queryAllowedURL
    }

    public enum CodingKeys: String, CodingKey {
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

    public init(
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

    public convenience init(id: Int) {
        self.init(
            id: id,
            typeID: 0,
            sizeID: 0,
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

public struct Photo: Codable, Identifiable, Equatable {
    public let id: Int
    public let stringURL: String?

    public var imageURL: URL? {
        stringURL.queryAllowedURL
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case stringURL = "photo"
    }

    public init(id: Int, stringURL: String? = nil) {
        self.id = id
        self.stringURL = stringURL
    }
}

public struct CommentResponse: Codable, Identifiable, Hashable {
    public let id: Int
    public let body, date: String?
    public let user: UserResponse?

    public var formattedBody: String {
        body.valueOrEmpty.withoutHTML
    }

    public enum CodingKeys: String, CodingKey {
        case id = "comment_id"
        case body, date, user
    }

    public var formattedDateString: String {
        DateFormatterService.readableDate(from: date)
    }

    public init(id: Int, body: String? = nil, date: String? = nil, user: UserResponse? = nil) {
        self.id = id
        self.body = body
        self.date = date
        self.user = user
    }
}

public extension SportsGround {
    var hasPhotos: Bool { !photos.isEmpty }

    var photos: [Photo] {
        get { photosOptional ?? [] }
        set { photosOptional = newValue }
    }

    var hasComments: Bool { !comments.isEmpty }

    var comments: [CommentResponse] {
        get { commentsOptional ?? [] }
        set { commentsOptional = newValue }
    }

    var hasParticipants: Bool { !participants.isEmpty }

    /// Пользователи, которые тренируются на этой площадке
    var participants: [UserResponse] {
        get { usersTrainHere ?? [] }
        set { usersTrainHere = newValue }
    }

    var participantsCountString: String {
        String.localizedStringWithFormat(
            NSLocalizedString("peopleCount", comment: ""),
            participants.count
        )
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
            id: 0,
            typeID: 0,
            sizeID: 0,
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
            usersTrainHereCount: 0,
            commentsOptional: nil,
            usersTrainHere: [],
            trainHere: nil
        )
    }
}
