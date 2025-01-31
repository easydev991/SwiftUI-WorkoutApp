import Foundation

public struct MediaFile: Codable, Equatable, Sendable {
    public let key: String
    public let filename: String
    public let data: Data
    public let mimeType: String

    /// Инициализатор для добавления фото площадки/мероприятия
    /// - Parameters:
    ///   - imageData: Данные для картинки
    ///   - key: Индекс
    public init(imageData: Data, forKey key: String) {
        self.key = "photo\(key)"
        self.mimeType = "image/jpeg"
        self.filename = "photo\(key).jpg"
        self.data = imageData
    }
}
