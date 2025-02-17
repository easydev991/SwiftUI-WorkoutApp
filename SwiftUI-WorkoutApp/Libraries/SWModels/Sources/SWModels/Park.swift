import Foundation
import MapKit.MKGeometry
import SWUtils

/// Модель данных спортивной площадки
public struct Park: Codable, Identifiable, Hashable, Sendable {
    public let id, typeID, sizeID: Int
    public let address: String?
    public let author: UserResponse?
    public let cityID, commentsCount: Int?
    public let createDate: String?
    public let latitude, longitude: String
    public let name: String?
    private var photosOptional: [Photo]?
    public let preview: String?
    public let usersTrainHereCount: Int?
    public var usersTrainHereText: String {
        String.localizedStringWithFormat(
            NSLocalizedString("peopleTrainHere", comment: ""),
            usersTrainHereCount ?? 0
        )
    }

    private var commentsOptional: [CommentResponse]?
    public var usersTrainHere: [UserResponse]?
    private var trainHereOptional: Bool?
    public var title: String? { "Площадка № \(id)" }
    public var subtitle: String? {
        let grade = NSLocalizedString(ParkGrade(id: typeID).rawValue, comment: "")
        let size = NSLocalizedString(ParkSize(id: sizeID).rawValue, comment: "")
        return grade + " / " + size
    }

    public var shortTitle: String { "№ \(id)" }
    /// shortTitle + subtitle
    public var longTitle: String {
        guard let subtitle else { return shortTitle }
        return shortTitle + " " + subtitle
    }

    public var authorID: Int {
        author?.id ?? 0
    }

    public var coordinate: CLLocationCoordinate2D {
        .init(
            latitude: .init(Double(latitude) ?? 0),
            longitude: .init(Double(longitude) ?? 0)
        )
    }

    /// Точка для карты
    public var annotation: MKAnnotation {
        ParkAnnotation(
            coordinate: coordinate,
            title: title,
            subtitle: subtitle
        )
    }

    /// Ссылка на координаты в стандартном приложении "Карты"
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
        case createDate = "create_date"
        case id, latitude, longitude, name, preview
        case usersTrainHereCount = "trainings"
        case commentsOptional = "comments"
        case photosOptional = "photos"
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
        createDate: String?,
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
        self.createDate = createDate
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
}

public struct Photo: Codable, Identifiable, Hashable, Sendable {
    public var id: String {
        "\(serverId)-\(stringURL ?? "")"
    }

    public let serverId: Int
    public let stringURL: String?

    public var imageURL: URL? {
        stringURL.queryAllowedURL
    }

    public enum CodingKeys: String, CodingKey {
        case serverId = "id"
        case stringURL = "photo"
    }

    public init(id: Int, stringURL: String?) {
        self.serverId = id
        self.stringURL = stringURL
    }
}

public struct CommentResponse: Codable, Identifiable, Hashable, Sendable {
    public let id: Int
    public let body, date: String?
    public let user: UserResponse?

    public var formattedBody: String {
        (body ?? "").withoutHTML
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

public extension Park {
    var hasPhotos: Bool { !photos.isEmpty }

    var photos: [Photo] {
        get { photosOptional ?? [] }
        set { photosOptional = newValue }
    }

    func removePhotoById(_ id: Int) -> [Photo] {
        PhotoRemover(initialPhotos: photos, removeId: id).photosAfterRemoval
    }

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
        get { trainHereOptional ?? false }
        set { trainHereOptional = newValue }
    }

    /// `true` - сервер прислал всю информацию о площадке, `false` - не всю
    var isFull: Bool {
        let needUpdateParticipants = usersTrainHereCount ?? 0 > 0 && participants.isEmpty
        let needUpdateComments = commentsCount ?? 0 > 0 && comments.isEmpty
        return createDate != nil
            && author != nil
            && !photos.isEmpty
            && !needUpdateParticipants
            && !needUpdateComments
    }

    /// Описание для `ShareLink`
    var shareLinkDescription: String {
        guard let address else { return longTitle }
        return [longTitle, address].joined(separator: "\n")
    }

    /// Ссылка на площадку для `ShareLink`
    var shareLinkURL: URL? {
        URL(string: "https://workout.su/areas/\(id)")
    }

    static var emptyValue: Park {
        .init(
            id: 0,
            typeID: 0,
            sizeID: 0,
            address: nil,
            author: .emptyValue,
            cityID: nil,
            commentsCount: nil,
            createDate: nil,
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

final class ParkAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?

    init(
        coordinate: CLLocationCoordinate2D,
        title: String?,
        subtitle: String?
    ) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
