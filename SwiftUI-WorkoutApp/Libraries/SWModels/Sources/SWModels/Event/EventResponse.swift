import Foundation
import SWUtils

/// Модель со всей информацией о мероприятии
public struct EventResponse: Codable, Identifiable, Equatable, Sendable, Hashable {
    public let id: Int
    /// Название мероприятия
    public var title: String?
    /// Описание мероприятия с `html`-тегами
    public var eventDescription: String?
    public let fullAddress: String?
    public var beginDate: String?
    public var countryId, cityId: Int?
    public let commentsCount: Int?
    public var commentsOptional: [CommentResponse]?
    public let previewImageStringURL: String?
    public var parkId: Int?
    public let latitude, longitude: String?
    /// Количество участников
    public let participantsCount: Int?
    public var participantsOptional: [UserResponse]?
    /// `true` - предстоящее мероприятие, `false` - прошедшее
    public let isCurrent: Bool?
    public var photosOptional: [Photo]?
    public let author: UserResponse?
    /// Участвует ли пользователь в мероприятии
    ///
    /// Сервер присылает `false`, если хотя бы раз успешно вызвать `deleteGoToEvent`,
    /// поэтому при итоговом определении статуса `trainHere` смотрим на список участников
    public var trainHereOptional: Bool?

    public enum CodingKeys: String, CodingKey {
        case id, title, latitude, longitude, author
        case fullAddress = "address"
        case previewImageStringURL = "preview"
        case eventDescription = "description"
        case beginDate = "begin_date"
        case countryId = "country_id"
        case cityId = "city_id"
        case commentsCount = "comment_count"
        case parkId = "area_id"
        case participantsCount = "user_count"
        case isCurrent = "is_current"
        case photosOptional = "photos"
        case participantsOptional = "training_users"
        case trainHereOptional = "train_here"
        case commentsOptional = "comments"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.eventDescription = try container.decodeIfPresent(String.self, forKey: .eventDescription)
        self.fullAddress = try container.decodeIfPresent(String.self, forKey: .fullAddress)
        self.beginDate = try container.decodeIfPresent(String.self, forKey: .beginDate)
        self.countryId = try container.decodeIfPresent(Int.self, forKey: .countryId)
        self.cityId = try container.decodeIfPresent(Int.self, forKey: .cityId)
        self.commentsCount = try container.decodeIfPresent(Int.self, forKey: .commentsCount)
        self.commentsOptional = try container.decodeIfPresent([CommentResponse].self, forKey: .commentsOptional)
        self.previewImageStringURL = try container.decodeIfPresent(String.self, forKey: .previewImageStringURL)
        self.parkId = container.decodeIntOrStringIfPresent(.parkId)
        self.latitude = try container.decodeIfPresent(String.self, forKey: .latitude)
        self.longitude = try container.decodeIfPresent(String.self, forKey: .longitude)
        self.participantsCount = container.decodeIntOrStringIfPresent(.participantsCount)
        self.participantsOptional = try container.decodeIfPresent([UserResponse].self, forKey: .participantsOptional)
        self.isCurrent = try container.decodeIfPresent(Bool.self, forKey: .isCurrent)
        self.photosOptional = try container.decodeIfPresent([Photo].self, forKey: .photosOptional)
        self.author = try container.decodeIfPresent(UserResponse.self, forKey: .author)
        self.trainHereOptional = try container.decodeIfPresent(Bool.self, forKey: .trainHereOptional)
    }

    public init(
        id: Int,
        title: String? = nil,
        eventDescription: String? = nil,
        fullAddress: String? = nil,
        beginDate: String? = nil,
        countryId: Int? = nil,
        cityId: Int? = nil,
        commentsCount: Int? = nil,
        commentsOptional: [CommentResponse]? = nil,
        previewImageStringURL: String? = nil,
        parkId: Int? = nil,
        latitude: String? = nil,
        longitude: String? = nil,
        participantsCount: Int? = nil,
        participantsOptional: [UserResponse]? = nil,
        isCurrent: Bool? = nil,
        photosOptional: [Photo]? = nil,
        author: UserResponse? = nil,
        trainHereOptional: Bool? = nil
    ) {
        self.id = id
        self.title = title
        self.eventDescription = eventDescription
        self.fullAddress = fullAddress
        self.beginDate = beginDate
        self.countryId = countryId
        self.cityId = cityId
        self.commentsCount = commentsCount
        self.commentsOptional = commentsOptional
        self.previewImageStringURL = previewImageStringURL
        self.parkId = parkId
        self.latitude = latitude
        self.longitude = longitude
        self.participantsCount = participantsCount
        self.participantsOptional = participantsOptional
        self.isCurrent = isCurrent
        self.photosOptional = photosOptional
        self.author = author
        self.trainHereOptional = trainHereOptional
    }
}

public extension EventResponse {
    var formattedTitle: String {
        get {
            guard let title else { return "" }
            return title
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .capitalizingFirstLetter
        }
        set { title = newValue }
    }

    var hasDescription: Bool {
        !formattedDescription.isEmpty
    }

    var formattedDescription: String {
        get {
            eventDescription.withoutHtmlOrEmpty()
        }
        set { eventDescription = newValue }
    }

    var park: Park {
        get {
            .init(
                id: parkId ?? 0,
                typeId: 0,
                sizeId: 0,
                address: fullAddress,
                author: author,
                cityId: cityId,
                commentsCount: nil,
                createDate: nil,
                latitude: latitude ?? "",
                longitude: longitude ?? "",
                name: nil,
                photosOptional: nil,
                preview: nil,
                usersTrainHereCount: nil,
                commentsOptional: nil,
                usersTrainHere: nil,
                trainHere: nil
            )
        }
        set {}
    }

    var previewImageURL: URL? {
        previewImageStringURL.queryAllowedURL
    }

    var eventBeginDateForCalendar: Date {
        DateFormatterService.dateFromIsoString(beginDate)
    }

    var eventDateString: String {
        DateFormatterService.readableDate(from: beginDate)
    }

    var comments: [CommentResponse] {
        get { commentsOptional ?? [] }
        set { commentsOptional = newValue }
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

    var hasParticipants: Bool {
        !participants.isEmpty
    }

    /// Список участников мероприятия
    var participants: [UserResponse] {
        get { participantsOptional ?? [] }
        set { participantsOptional = newValue }
    }

    var participantsCountString: String {
        String.localizedStringWithFormat(
            NSLocalizedString("peopleCount", bundle: .module, comment: ""),
            participants.count
        )
    }

    /// Пользователь участвует в этом мероприятии
    var trainHere: Bool {
        get { trainHereOptional ?? false }
        set { trainHereOptional = newValue }
    }

    var authorId: Int {
        author?.id ?? 0
    }

    /// `true` - сервер прислал всю информацию о мероприятии, `false` - не всю
    var isFull: Bool {
        let needUpdateParticipants = participantsCount ?? 0 > 0 && participants.isEmpty
        let needUpdateComments = commentsCount ?? 0 > 0 && comments.isEmpty
        return !needUpdateParticipants && !needUpdateComments
    }

    /// Описание для `ShareLink`
    var shareLinkDescription: String {
        guard let fullAddress else {
            return [formattedTitle, eventDateString].joined(separator: "\n")
        }
        return [formattedTitle, eventDateString, fullAddress].joined(separator: "\n")
    }

    /// Ссылка на мероприятие для `ShareLink`
    var shareLinkURL: URL? {
        URL(string: "https://workout.su/trainings/\(id)")
    }

    static var emptyValue: EventResponse {
        .init(
            id: 0,
            title: nil,
            eventDescription: nil,
            fullAddress: nil,
            beginDate: nil,
            countryId: nil,
            cityId: nil,
            commentsCount: nil,
            commentsOptional: nil,
            previewImageStringURL: nil,
            parkId: nil,
            latitude: nil,
            longitude: nil,
            participantsCount: nil,
            participantsOptional: nil,
            isCurrent: nil,
            photosOptional: nil,
            author: nil,
            trainHereOptional: nil
        )
    }
}

public extension [EventResponse] {
    /// Сортирует события по дате начала в порядке убывания (новые события с более поздней датой идут первыми)
    var sortedByDate: [EventResponse] {
        sorted { event1, event2 in
            let date1 = DateFormatterService.dateFromIsoString(event1.beginDate)
            let date2 = DateFormatterService.dateFromIsoString(event2.beginDate)
            return date1 > date2
        }
    }
}
