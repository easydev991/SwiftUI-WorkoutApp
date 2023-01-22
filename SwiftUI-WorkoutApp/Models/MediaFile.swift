import Foundation

struct MediaFile: Codable {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String

    init(imageData: Data, forKey key: String) {
        self.key = "photo\(key)"
        self.mimeType = "image/jpeg"
        self.filename = "photo\(key).jpg"
        self.data = imageData
    }
}
