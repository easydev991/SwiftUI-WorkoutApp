import Foundation
import UIKit.UIImage

struct MediaFile: Codable {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String

    init(withImage image: UIImage, forKey key: String) {
        self.key = "photo\(key)"
        self.mimeType = "image/jpeg"
        self.filename = "photo\(key).jpg"
        self.data = image.jpegData(compressionQuality: 1) ?? .init()
    }
}
