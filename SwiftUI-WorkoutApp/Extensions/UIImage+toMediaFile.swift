import SWModels
import UIKit.UIImage

extension UIImage {
    /// Делает медиафайл из картинки
    ///
    /// Сначала пробуем конвертацию через jpegData для скорости, но в случае проблем обращаемся к `UIGraphicsImageRenderer` для
    /// гарантированного результата
    func toMediaFile(with key: String = "") -> MediaFile? {
        let data = jpegData(compressionQuality: 1) ?? UIGraphicsImageRenderer(size: size).jpegData(withCompressionQuality: 1) { _ in
            draw(in: .init(), blendMode: .normal, alpha: 1)
        }
        return data.isEmpty ? nil : MediaFile(imageData: data, forKey: key)
    }
}

extension [UIImage] {
    /// Создает список медиафайлов из картинок для отправки на сервер
    var toMediaFiles: [MediaFile] {
        enumerated().compactMap { index, image in
            image.toMediaFile(with: "\(index + 1)")
        }
    }
}
