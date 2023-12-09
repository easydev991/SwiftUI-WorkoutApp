import Foundation
import Utils

/// Форма для отправки создании/изменении мероприятия
public struct EventForm: Codable, Sendable, Equatable {
    public var title, description: String
    public var date: Date
    public var sportsGroundID: Int
    public var sportsGroundName: String
    public let photosCount: Int
    public var newMediaFiles: [MediaFile]

    /// Основной инициализатор
    public init(
        title: String = "",
        description: String = "",
        date: Date = .now,
        sportsGroundID: Int = 0,
        sportsGroundName: String? = nil,
        photosCount: Int = 0,
        newMediaFiles: [MediaFile] = []
    ) {
        self.title = title
        self.description = description
        self.date = date
        self.sportsGroundID = sportsGroundID
        self.sportsGroundName = sportsGroundName ?? "Выбрать площадку"
        self.photosCount = photosCount
        self.newMediaFiles = newMediaFiles
    }

    /// Инициализатор для создания формы на основе существующего мероприятия
    public init(_ event: EventResponse?) {
        let ground = event?.sportsGround
        let groundID = ground?.id ?? event?.sportsGroundID
        let groundName = ground?.name ?? ground?.longTitle ?? ground?.title
        self.init(
            title: event?.formattedTitle ?? "",
            description: event?.formattedDescription ?? "",
            date: DateFormatterService.dateFromIsoString(event?.beginDate),
            sportsGroundID: groundID ?? 0,
            sportsGroundName: groundName ?? "Выбрать площадку",
            photosCount: event?.photos.count ?? 0
        )
    }

    public init(_ groundID: Int, _ groundName: String) {
        self.init(
            sportsGroundID: groundID,
            sportsGroundName: groundName
        )
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
