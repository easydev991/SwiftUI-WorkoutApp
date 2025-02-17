import ImagePicker
import SWDesignSystem
import SwiftUI

struct PickedImagesGrid: View {
    private var imagesArray: [PickedImageView.Model] {
        var realImages: [PickedImageView.Model] = images.map {
            .image($0)
        }
        if selectionLimit > 0 {
            realImages.append(.addImageButton)
        }
        return realImages
    }

    @State private var fullscreenImageInfo: PhotoDetailScreen.Model?
    @Binding var images: [UIImage]
    @Binding var showImagePicker: Bool
    /// Сколько еще можно выбрать фотографий
    let selectionLimit: Int
    /// Обработать добавление лишних фотографий
    ///
    /// У стандартного пикера есть баг: иногда можно нажать на фото больше раз, чем позволяет лимит
    let processExtraImages: () -> Void

    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                ModernPickedImagesGrid(
                    images: $images,
                    showImagePicker: $showImagePicker,
                    selectionLimit: selectionLimit
                )
            } else {
                oldContentView
                    .sheet(isPresented: $showImagePicker) {
                        processExtraImages()
                    } content: {
                        ImagePicker(
                            pickedImages: $images,
                            selectionLimit: selectionLimit,
                            compressionQuality: 0
                        )
                    }
            }
        }
        .animation(.default, value: images.count)
    }
}

private extension PickedImagesGrid {
    var header: String { ImagePickerViews.makeHeaderString(for: images.count) }

    @MainActor
    var oldContentView: some View {
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
    }

    func deletePhoto(at index: Int) {
        images.remove(at: index)
        fullscreenImageInfo = nil
    }
}

#if DEBUG
#Preview("Лимит 10, есть 0") {
    PickedImagesGrid(
        images: .constant([]),
        showImagePicker: .constant(false),
        selectionLimit: 10,
        processExtraImages: {}
    )
}

#Preview("Лимит 7, есть 3") {
    let images: [UIImage] = Array(1 ... 3).map {
        .init(systemName: "\($0).circle.fill")!
    }
    return PickedImagesGrid(
        images: .constant(images),
        showImagePicker: .constant(false),
        selectionLimit: 7,
        processExtraImages: {}
    )
}

#Preview("Лимит 0, есть 10") {
    let images: [UIImage] = Array(1 ... 10).map {
        .init(systemName: "\($0).circle.fill")!
    }
    return PickedImagesGrid(
        images: .constant(images),
        showImagePicker: .constant(false),
        selectionLimit: 0,
        processExtraImages: {}
    )
}

#Preview("Лимит 0, есть 0") {
    PickedImagesGrid(
        images: .constant([]),
        showImagePicker: .constant(false),
        selectionLimit: 0,
        processExtraImages: {}
    )
}
#endif
