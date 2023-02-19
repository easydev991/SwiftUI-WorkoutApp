import SWModels
import UIKit.UIImage

extension [UIImage] {
    /// Создает список медиафайлов из картинок для отправки на сервер
    var toMediaFiles: [MediaFile] {
        enumerated().compactMap { index, image in
            guard let imageData = image.jpegData(compressionQuality: 1) else { return nil }
            return .init(imageData: imageData, forKey: "\(index + 1)")
        }
    }
}
