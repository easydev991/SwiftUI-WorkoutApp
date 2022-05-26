import PhotosUI
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = .zero
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        .init(with: self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(with parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            results.forEach { image in
                if image.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    image.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] result, error in
                        if let selectedImage = result as? UIImage,
                           let data = selectedImage.jpegData(compressionQuality: 0.1),
                           let compressedImage = UIImage(data: data) {
                            self?.parent.selectedImages.append(compressedImage)
                        } else {
                            print("didFinishPicking error: \(error?.localizedDescription ?? "")")
                        }
                    }
                } else {
                    print("Ошибка: не удается загрузить картинку")
                }
            }
            picker.dismiss(animated: true)
        }
    }
}
