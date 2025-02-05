import PhotosUI
import SWDesignSystem
import SwiftUI
import SWUtils

/// Сетка для добавления фотографий с использованием `PhotosPicker`
@available(iOS 16.0, *)
struct ModernPickedImagesGrid: View {
    private var imagesArray: [PickedImageView.Model] {
        var realImages = images.map(PickedImageView.Model.image)
        if selectionLimit > 0 {
            realImages.append(.addImageButton)
        }
        return realImages
    }

    @State private var fullscreenImageInfo: PhotoDetailScreen.Model?
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var isLoading = false
    @Binding var images: [UIImage]
    @Binding var showImagePicker: Bool
    let selectionLimit: Int

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
                            showImagePicker.toggle()
                        case .deleteImage:
                            deletePhoto(at: index)
                        case let .showDetailImage(uiImage):
                            fullscreenImageInfo = .init(uiImage: uiImage, id: index)
                        }
                    }
                )
            }
            .fullScreenCover(item: $fullscreenImageInfo) {
                fullscreenImageInfo = nil
            } content: { model in
                PhotoDetailScreen(
                    model: model,
                    canDelete: true,
                    reportPhotoClbk: {},
                    deletePhotoClbk: deletePhoto
                )
            }
        }
        .loadingOverlay(if: isLoading)
        .photosPicker(
            isPresented: $showImagePicker,
            selection: $selectedItems,
            matching: .any(of: [.images, .panoramas])
        )
        .task(id: selectedItems) {
            do {
                isLoading.toggle()
                // TODO: Вывод картинок тяжелая задача, можно оптимизировать
                let newImages = try await loadImages(from: selectedItems)
                images.append(contentsOf: newImages)
            } catch {
                SWAlert.shared.presentDefaultUIKit(error)
            }
            selectedItems.removeAll()
            isLoading.toggle()
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

    func deletePhoto(at index: Int) {
        images.remove(at: index)
        fullscreenImageInfo = nil
    }

    enum ImageError: Error, LocalizedError {
        case dataLoadingFailed
        case imageCreationFailed

        var errorDescription: String? {
            switch self {
            case .dataLoadingFailed: "ImageErrorDataLoadingFailed".localized
            case .imageCreationFailed: "ImageErrorImageCreationFailed".localized
            }
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Лимит 10, есть 0") {
    ModernPickedImagesGrid(
        images: .constant([]),
        showImagePicker: .constant(false),
        selectionLimit: 10
    )
}

@available(iOS 16.0, *)
#Preview("Лимит 7, есть 3") {
    let images: [UIImage] = Array(1 ... 3).map {
        .init(systemName: "\($0).circle.fill")!
    }
    ModernPickedImagesGrid(
        images: .constant(images),
        showImagePicker: .constant(false),
        selectionLimit: 7
    )
}

@available(iOS 16.0, *)
#Preview("Лимит 0, есть 10") {
    let images: [UIImage] = Array(1 ... 10).map {
        .init(systemName: "\($0).circle.fill")!
    }
    ModernPickedImagesGrid(
        images: .constant(images),
        showImagePicker: .constant(false),
        selectionLimit: 0
    )
}

@available(iOS 16.0, *)
#Preview("Лимит 0, есть 0") {
    ModernPickedImagesGrid(
        images: .constant([]),
        showImagePicker: .constant(false),
        selectionLimit: 0
    )
}
#endif
