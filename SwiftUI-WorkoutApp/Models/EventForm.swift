import Foundation

/// Форма для отправки создании/изменении мероприятия
struct EventForm: Codable {
    var title, description: String
    var date: Date
    var sportsGround: SportsGround
    let photosCount: Int
    var newImagesData = [MediaFile]()

    init(_ event: EventResponse?) {
        self.title = (event?.formattedTitle).valueOrEmpty
        self.description = (event?.formattedDescription).valueOrEmpty
        self.date = FormatterService.dateFromIsoString(event?.beginDate, format: .isoDateTimeSec)
        self.sportsGround = event?.sportsGround ?? .emptyValue
        self.photosCount = (event?.photos?.count).valueOrZero
    }
}

extension EventForm {
    /// Пример: "1990-08-12T00:00:00.000Z"
    var dateIsoString: String {
        FormatterService.stringFromFullDate(date)
    }

    var countryID: Int {
        sportsGround.countryID.valueOrZero
    }

    var cityID: Int {
        sportsGround.cityID.valueOrZero
    }

    /// Готовность формы к отправке
    var isReadyToSend: Bool {
        !title.isEmpty
        && !description.isEmpty
        && sportsGround.id != .zero
    }

    static var emptyValue: Self {
        .init(nil)
    }
}
