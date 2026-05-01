import SWDesignSystem
import SwiftUI

struct PickedImagesGrid: View {
    private var imagesArray: [PickedImageView.Model] {
        var realImages = images.map(PickedImageView.Model.image)
        if selectionLimit > 0 {
            realImages.append(.addImageButton)
        }
        return realImages
    }

    @State private var presentedItem: PresentedItem?
    /// Диалог для выбора источника фото (камера/галерея)
    @State private var showImagePickerDialog = false
    /// Тоггл для отображения фото в галерее
    @State private var showImagePicker = false
    @Binding var images: [UIImage]
    /// Сколько еще можно выбрать фотографий
    let selectionLimit: Int

    var body: some View {
        ModernPickedImagesGrid(
            imagesArray: imagesArray,
            presentedItem: $presentedItem,
            images: $images,
            showImagePickerDialog: $showImagePickerDialog,
            showPhotosPicker: $showImagePicker,
            selectionLimit: selectionLimit,
            deletePhoto: deletePhoto
        )
        .animation(.default, value: images.count)
        .confirmationDialog(
            "",
            isPresented: $showImagePickerDialog,
            titleVisibility: .hidden
        ) {
            Button("Сделать фото") {
                presentedItem = .takePhoto
            }
            Button("Выбрать из галереи") {
                showImagePicker = true
            }
        }
        .fullScreenCover(
            item: $presentedItem,
            content: { item in
                switch item {
                case .takePhoto:
                    SWImagePicker(sourceType: .camera) { images.append($0) }
                        .ignoresSafeArea()
                case let .viewImage(model):
                    PhotoDetailScreen(
                        model: model,
                        canDelete: true,
                        reportPhotoClbk: {},
                        deletePhotoClbk: deletePhoto
                    )
                }
            }
        )
    }
}

extension PickedImagesGrid {
    enum PresentedItem: Identifiable {
        var id: String {
            switch self {
            case .takePhoto: "takePhoto"
            case let .viewImage(model): "viewImage-\(model.id)"
            }
        }

        case takePhoto
        case viewImage(model: PhotoDetailScreen.Model)
    }
}

private extension PickedImagesGrid {
    func deletePhoto(at index: Int) {
        images.remove(at: index)
        presentedItem = nil
    }
}

#if DEBUG
#Preview("Лимит 10, есть 0") {
    PickedImagesGrid(
        images: .constant([]),
        selectionLimit: 10
    )
}

#Preview("Лимит 7, есть 3") {
    let images: [UIImage] = Array(1 ... 3).map {
        .init(systemName: "\($0).circle.fill")!
    }
    return PickedImagesGrid(
        images: .constant(images),
        selectionLimit: 7
    )
}

#Preview("Лимит 0, есть 10") {
    let images: [UIImage] = Array(1 ... 10).map {
        .init(systemName: "\($0).circle.fill")!
    }
    return PickedImagesGrid(
        images: .constant(images),
        selectionLimit: 0
    )
}

#Preview("Лимит 0, есть 0") {
    PickedImagesGrid(
        images: .constant([]),
        selectionLimit: 0
    )
}
#endif
