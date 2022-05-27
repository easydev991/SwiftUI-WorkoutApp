import PhotosUI
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Binding var showPicker: Bool

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

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(with parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            results.forEach { image in
                if image.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    image.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] result, error in
                        if let selectedImage = result as? UIImage,
                           let data = selectedImage.jpegData(compressionQuality: .zero),
                           let compressedImage = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self?.parent.selectedImages.append(compressedImage)
                            }
                        } else {
                            print("didFinishPicking error: \(error?.localizedDescription ?? "")")
                        }
                    }
                } else {
                    print("Ошибка: не удается загрузить картинку")
                }
            }
            parent.showPicker.toggle()
        }
    }
}
