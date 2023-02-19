import Foundation

public struct MediaFile: Codable {
    public let key: String
    public let filename: String
    public let data: Data
    public let mimeType: String

    public init(imageData: Data, forKey key: String) {
        self.key = "photo\(key)"
        self.mimeType = "image/jpeg"
        self.filename = "photo\(key).jpg"
        self.data = imageData
    }
}
