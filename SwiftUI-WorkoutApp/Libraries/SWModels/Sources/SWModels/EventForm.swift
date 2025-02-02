import Foundation
import SWUtils

/// Форма для отправки создании/изменении мероприятия
public struct EventForm: Codable, Sendable, Equatable {
    public var title, description: String
    public var date: Date
    public var parkID: Int
    public var parkName: String
    public let photosCount: Int
    public var newMediaFiles: [MediaFile]

    /// Основной инициализатор
    public init(
        title: String = "",
        description: String = "",
        date: Date = .now,
        parkID: Int = 0,
        parkName: String? = nil,
        photosCount: Int = 0,
        newMediaFiles: [MediaFile] = []
    ) {
        self.title = title
        self.description = description
        self.date = date
        self.parkID = parkID
        self.parkName = parkName ?? "Выбрать площадку"
        self.photosCount = photosCount
        self.newMediaFiles = newMediaFiles
    }

    /// Инициализатор для создания формы на основе существующего мероприятия
    public init(_ event: EventResponse?) {
        let park = event?.park
        let parkID = park?.id ?? event?.parkID
        let parkName = park?.longTitle ?? park?.title
        self.init(
            title: event?.formattedTitle ?? "",
            description: event?.formattedDescription ?? "",
            date: DateFormatterService.dateFromIsoString(event?.beginDate),
            parkID: parkID ?? 0,
            parkName: parkName ?? "Выбрать площадку",
            photosCount: event?.photos.count ?? 0
        )
    }

    public init(_ parkID: Int, _ parkName: String) {
        self.init(
            parkID: parkID,
            parkName: parkName
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
        !title.isEmpty && !description.isEmpty && parkID != 0
    }

    /// Готовность формы к отправке обновлений по мероприятию
    func isReadyToUpdate(old: EventForm) -> Bool {
        let isNewFormNotEmpty = !title.isEmpty && !description.isEmpty
        return isNewFormNotEmpty && self != old
    }

    static var emptyValue: Self { .init(nil) }
}
