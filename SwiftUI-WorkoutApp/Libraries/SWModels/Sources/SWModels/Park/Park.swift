import Foundation
import MapKit.MKGeometry
import SWUtils

/// Модель данных спортивной площадки
public struct Park: Codable, Identifiable, Hashable, Sendable {
    public let id, typeId, sizeId: Int
    let address: String?
    public let author: UserResponse?
    public let cityId, commentsCount: Int?
    public let createDate: String?
    public let latitude, longitude: String
    public let name: String?
    private var photosOptional: [Photo]?
    public let preview: String?
    public let usersTrainHereCount: Int?
    public var usersTrainHereText: String {
        String.localizedStringWithFormat(
            NSLocalizedString("peopleTrainHere", bundle: .module, comment: ""),
            usersTrainHereCount ?? 0
        )
    }

    private var commentsOptional: [CommentResponse]?
    public var usersTrainHere: [UserResponse]?
    private var trainHereOptional: Bool?
    public var title: String? {
        "Площадка № \(id)"
    }

    public var subtitle: String {
        let grade = ParkGrade(rawValue: typeId)?.description
        let size = ParkSize(rawValue: sizeId)?.description
        return [grade, size].compactMap(\.self).joined(separator: " / ")
    }

    public var shortTitle: String {
        "№ \(id)"
    }

    /// shortTitle + subtitle
    public var longTitle: String {
        shortTitle + " " + subtitle
    }

    public var authorId: Int {
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
        case cityId = "city_id"
        case sizeId = "class_id"
        case commentsCount = "comments_count"
        case createDate = "create_date"
        case id, latitude, longitude, name, preview
        case usersTrainHereCount = "trainings"
        case commentsOptional = "comments"
        case photosOptional = "photos"
        case typeId = "type_id"
        case trainHereOptional = "train_here"
        case usersTrainHere = "users_train_here"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIntOrString(.id)
        self.typeId = try container.decodeIntOrString(.typeId)
        self.sizeId = try container.decodeIntOrString(.sizeId)
        self.cityId = container.decodeIntOrStringIfPresent(.cityId)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        self.author = try container.decodeIfPresent(UserResponse.self, forKey: .author)
        self.commentsCount = try container.decodeIfPresent(Int.self, forKey: .commentsCount)
        self.createDate = try container.decodeIfPresent(String.self, forKey: .createDate)
        self.latitude = try container.decode(String.self, forKey: .latitude)
        self.longitude = try container.decode(String.self, forKey: .longitude)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.photosOptional = try container.decodeIfPresent([Photo].self, forKey: .photosOptional)
        self.preview = try container.decodeIfPresent(String.self, forKey: .preview)
        self.usersTrainHereCount = try container.decodeIfPresent(Int.self, forKey: .usersTrainHereCount)
        self.commentsOptional = try container.decodeIfPresent([CommentResponse].self, forKey: .commentsOptional)
        self.usersTrainHere = try container.decodeIfPresent([UserResponse].self, forKey: .usersTrainHere)
        self.trainHereOptional = try container.decodeIfPresent(Bool.self, forKey: .trainHereOptional)
    }

    public init(
        id: Int,
        typeId: Int,
        sizeId: Int,
        address: String?,
        author: UserResponse?,
        cityId: Int?,
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
        self.typeId = typeId
        self.sizeId = sizeId
        self.address = address
        self.author = author
        self.cityId = cityId
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
        body.withoutHtmlOrEmpty()
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
    /// Проверенный адрес (плейсхолдер, если нет текста)
    var checkedAddress: String {
        if let address, address.trueCount > 0 {
            address
        } else {
            String(localized: .addressNotSet)
        }
    }

    var hasPhotos: Bool {
        !photos.isEmpty
    }

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

    var hasParticipants: Bool {
        !participants.isEmpty
    }

    /// Пользователи, которые тренируются на этой площадке
    var participants: [UserResponse] {
        get { usersTrainHere ?? [] }
        set { usersTrainHere = newValue }
    }

    var participantsCountString: String {
        String.localizedStringWithFormat(
            NSLocalizedString("peopleCount", bundle: .module, comment: ""),
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
            typeId: 0,
            sizeId: 0,
            address: nil,
            author: .emptyValue,
            cityId: nil,
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
            trainHere: false
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
