import Foundation
import Utils

/// Форма для отправки создании/изменении мероприятия
public struct EventForm: Codable, Sendable, Equatable {
    public var title, description: String
    public var date: Date
    public var sportsGroundID: Int
    public var sportsGroundName: String
    public let photosCount: Int
    public var newMediaFiles = [MediaFile]()

    public init(_ event: EventResponse?) {
        self.title = event?.formattedTitle ?? ""
        self.description = event?.formattedDescription ?? ""
        self.date = DateFormatterService.dateFromIsoString(event?.beginDate)
        let groundName = event?.sportsGround.name ?? event?.sportsGround.longTitle
        self.sportsGroundName = groundName ?? "Выбрать площадку"
        self.sportsGroundID = event?.sportsGroundID ?? 0
        self.photosCount = event?.photos.count ?? 0
    }
    
    public init(_ groundID: Int, _ groundName: String) {
        self.title = ""
        self.description = ""
        self.date = .now
        self.sportsGroundID = groundID
        self.sportsGroundName = groundName
        self.photosCount = 0
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

    /// Сколько еще фотографий можно добавить с учетом имеющихся
    var imagesLimit: Int {
        Constants.photosLimit - newMediaFiles.count - photosCount
    }

    /// Готовность формы к созданию нового мероприятия
    var isReadyToCreate: Bool {
        !title.isEmpty && !description.isEmpty && sportsGroundID != .zero
    }

    /// Готовность формы к отправке обновлений по мероприятию
    func isReadyToUpdate(old: EventForm) -> Bool {
        self != old
    }

    static var emptyValue: Self { .init(nil) }
}
