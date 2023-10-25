import Foundation
import Utils

/// Форма для отправки создании/изменении мероприятия
public struct EventForm: Codable {
    public var title, description: String
    public var date: Date
    public var sportsGround: SportsGround
    public let photosCount: Int
    public var newMediaFiles = [MediaFile]()

    public init(_ event: EventResponse?) {
        self.title = event?.formattedTitle ?? ""
        self.description = event?.formattedDescription ?? ""
        self.date = DateFormatterService.dateFromIsoString(event?.beginDate)
        self.sportsGround = event?.sportsGround ?? .emptyValue
        self.photosCount = event?.photos.count ?? 0
    }
}

public extension EventForm {
    /// Пример: "2022-05-30T19:32:00"
    var dateIsoString: String {
        DateFormatterService.stringFromFullDate(
            date,
            format: .serverDateTimeSec,
            iso: false
        )
    }

    var countryID: Int {
        sportsGround.countryID ?? 0
    }

    var cityID: Int {
        sportsGround.cityID ?? 0
    }

    /// Готовность формы к созданию нового мероприятия
    var isReadyToCreate: Bool {
        !title.isEmpty
            && !description.isEmpty
            && sportsGround.id != .zero
    }

    /// Готовность формы к отправке обновлений по мероприятию
    func isReadyToUpdate(old: EventForm) -> Bool {
        isReadyToCreate && self != old
    }

    static var emptyValue: Self { .init(nil) }
}

extension EventForm: Equatable {
    public static func == (lhs: EventForm, rhs: EventForm) -> Bool {
        lhs.title == rhs.title
            && lhs.description == rhs.description
            && lhs.sportsGround.id == rhs.sportsGround.id
            && lhs.date == rhs.date
    }
}
