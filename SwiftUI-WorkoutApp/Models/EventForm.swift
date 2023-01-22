import Foundation
import DateFormatterService

/// Форма для отправки создании/изменении мероприятия
struct EventForm: Codable {
    var title, description: String
    var date: Date
    var sportsGround: SportsGround
    let photosCount: Int
    var newMediaFiles = [MediaFile]()

    init(_ event: EventResponse?) {
        self.title = (event?.formattedTitle).valueOrEmpty
        self.description = (event?.formattedDescription).valueOrEmpty
        self.date = DateFormatterService.dateFromIsoString(event?.beginDate, format: .isoDateTimeSec)
        self.sportsGround = event?.sportsGround ?? .emptyValue
        self.photosCount = (event?.photos.count).valueOrZero
    }
}

extension EventForm {
    /// Пример: "2022-05-30T19:32:00"
    var dateIsoString: String {
        DateFormatterService.stringFromFullDate(
            date,
            format: .serverDateTimeSec,
            iso: false
        )
    }

    var countryID: Int {
        sportsGround.countryID.valueOrZero
    }

    var cityID: Int {
        sportsGround.cityID.valueOrZero
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
    static func == (lhs: EventForm, rhs: EventForm) -> Bool {
        lhs.title == rhs.title
        && lhs.description == rhs.description
        && lhs.sportsGround.id == rhs.sportsGround.id
        && lhs.date == rhs.date
    }
}
