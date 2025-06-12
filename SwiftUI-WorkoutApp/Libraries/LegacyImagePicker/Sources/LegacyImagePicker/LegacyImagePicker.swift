import PhotosUI
import SwiftUI

/// A `PHPickerViewController` wrapped inside a `UIViewControllerRepresentable`
///
/// The picker will be automatically dismissed when the user
/// - completes a selection using the `Add` button (or by tapping a single photo with `selectionLimit` set to `1`)
/// - dismisses `PHPickerViewController` using the `Cancel` button
public struct LegacyImagePicker: UIViewControllerRepresentable {
    @Binding private var pickedImages: [UIImage]
    /// The maximum number of photos that can be selected. Default is 1.
    ///
    /// - Setting `selectionLimit` to 0 means maximum supported by the system.
    /// - The more photos the user selects, the longer it will take the system to get them in your app.
    private var selectionLimit = 1
    /// The quality of the resulting JPEG image, expressed as a value from `0.0` to `1.0`.
    ///
    /// - The value `0.0` represents the maximum compression (or lowest quality) while the value `1.0` represents the least compression (or best quality).
    /// - If not specified, no compression will be applied.
    private let compressionQuality: CGFloat?

    public init(
        pickedImages: Binding<[UIImage]>,
        selectionLimit: Int = 1,
        compressionQuality: CGFloat? = nil
    ) {
        _pickedImages = pickedImages
        self.selectionLimit = selectionLimit
        self.compressionQuality = compressionQuality
    }

    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = selectionLimit
        let viewController = PHPickerViewController(configuration: configuration)
        viewController.delegate = context.coordinator
        return viewController
    }

    public func updateUIViewController(_: PHPickerViewController, context _: Context) {}

    public func makeCoordinator() -> Coordinator { .init(self) }

    public final class Coordinator: PHPickerViewControllerDelegate {
        private let parent: LegacyImagePicker

        init(_ parent: LegacyImagePicker) {
            self.parent = parent
        }

        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            let imageItems = results
                .map(\.itemProvider)
                .filter { $0.canLoadObject(ofClass: UIImage.self) }
            let group = DispatchGroup()
            var finalArray = [UIImage]()
            for item in imageItems {
                group.enter()
                item.loadObject(ofClass: UIImage.self) { [weak self] element, _ in
                    if let image = element as? UIImage {
                        let finalImage: UIImage
                        if let compressionQuality = self?.parent.compressionQuality,
                           let compressedData = image.jpegData(compressionQuality: compressionQuality),
                           let compressedImage = UIImage(data: compressedData) {
                            finalImage = compressedImage
                        } else {
                            finalImage = image
                        }
                        finalArray.append(finalImage)
                    }
                    group.leave()
                }
            }
            group.notify(queue: .main) { [weak self] in
                self?.parent.pickedImages.append(contentsOf: finalArray)
                picker.dismiss(animated: true)
            }
        }
    }
}
