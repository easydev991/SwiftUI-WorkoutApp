import UIKit

extension UIImagePickerController.SourceType: @retroactive Identifiable {
    public var id: String {
        switch self {
        case .camera: "camera"
        case .photoLibrary: "photoLibrary"
        case .savedPhotosAlbum: "savedPhotosAlbum"
        @unknown default: fatalError()
        }
    }
}
