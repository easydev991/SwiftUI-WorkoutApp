import PhotosUI
import SWDesignSystem
import SwiftUI
import SWUtils

/// Сетка для добавления фотографий с использованием `PhotosPicker`
@available(iOS 16.0, *)
struct ModernPickedImagesGrid: View {
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var isLoading = false
    let imagesArray: [PickedImageView.Model]
    @Binding var presentedItem: PickedImagesGrid.PresentedItem?
    @Binding var images: [UIImage]
    @Binding var showImagePickerDialog: Bool
    @Binding var showPhotosPicker: Bool
    let selectionLimit: Int
    let deletePhoto: (_ index: Int) -> Void

    var body: some View {
        SectionView(header: .init(header), mode: .regular) {
            VStack(alignment: .leading, spacing: 12) {
                ImagePickerViews.makeSubtitleView(
                    selectionLimit: selectionLimit,
                    isEmpty: images.isEmpty
                )
                ImagePickerViews.makeGridView(
                    items: imagesArray,
                    action: { index, option in
                        switch option {
                        case .addImage:
                            showImagePickerDialog.toggle()
                        case .deleteImage:
                            deletePhoto(index)
                        case let .showDetailImage(uiImage):
                            presentedItem = .viewImage(model: .init(uiImage: uiImage, id: index))
                        }
                    }
                )
            }
        }
        .loadingOverlay(if: isLoading)
        .photosPicker(
            isPresented: $showPhotosPicker,
            selection: $selectedItems,
            matching: .any(of: [.images, .panoramas])
        )
        .task(id: selectedItems) {
            isLoading = true
            do {
                // TODO: Вывод картинок тяжелая задача, можно оптимизировать
                let newImages = try await loadImages(from: selectedItems)
                images.append(contentsOf: newImages)
            } catch {
                SWAlert.shared.presentDefaultUIKit(error)
            }
            selectedItems.removeAll()
            isLoading = false
        }
    }
}

@available(iOS 16.0, *)
private extension ModernPickedImagesGrid {
    var header: String { ImagePickerViews.makeHeaderString(for: images.count) }

    func loadImages(from selectedItems: [PhotosPickerItem]) async throws -> [UIImage] {
        try await withThrowingTaskGroup(of: UIImage.self) { group in
            for item in selectedItems {
                group.addTask {
                    guard let data = try await item.loadTransferable(type: Data.self) else {
                        throw ImageError.dataLoadingFailed
                    }
                    guard let image = UIImage(data: data) else {
                        throw ImageError.imageCreationFailed
                    }
                    return image
                }
            }
            var images = [UIImage]()
            for try await image in group {
                images.append(image)
            }
            return images
        }
    }

    enum ImageError: Error, LocalizedError {
        case dataLoadingFailed
        case imageCreationFailed

        var errorDescription: String? {
            switch self {
            case .dataLoadingFailed: NSLocalizedString("Error.Media.ImageLoad", comment: "")
            case .imageCreationFailed: NSLocalizedString("Error.Media.ImageCreation", comment: "")
            }
        }
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview("Лимит 10, есть 0") {
    @Previewable @State var presentedItem: PickedImagesGrid.PresentedItem?
    @Previewable @State var showImagePickerDialog = false
    @Previewable @State var showPhotosPicker = false

    ModernPickedImagesGrid(
        imagesArray: [],
        presentedItem: $presentedItem,
        images: .constant([]),
        showImagePickerDialog: $showImagePickerDialog,
        showPhotosPicker: $showPhotosPicker,
        selectionLimit: 10,
        deletePhoto: { _ in }
    )
}
#endif
