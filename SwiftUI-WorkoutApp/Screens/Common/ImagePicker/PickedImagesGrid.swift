import ImagePicker
import SWDesignSystem
import SwiftUI

struct PickedImagesGrid: View {
    @MainActor
    private var screenWidth: CGFloat { UIScreen.main.bounds.size.width }
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
        SectionView(header: .init(header), mode: .regular) {
            VStack(alignment: .leading, spacing: 12) {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.swMainText)
                    .multilineTextAlignment(.leading)
                LazyVGrid(
                    columns: .init(
                        repeating: .init(
                            .flexible(minimum: screenWidth * 0.287),
                            spacing: 11
                        ),
                        count: 3
                    ),
                    spacing: 12
                ) {
                    ForEach(Array(zip(imagesArray.indices, imagesArray)), id: \.0) { index, model in
                        GeometryReader { geo in
                            PickedImageView(
                                model: model,
                                height: geo.size.width,
                                action: { option in
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
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(8)
                    }
                }
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

private extension PickedImagesGrid {
    var header: String {
        String.localizedStringWithFormat(
            NSLocalizedString("photoSectionHeader", comment: ""),
            images.count
        )
    }

    var subtitle: String {
        guard selectionLimit > 0 else {
            return NSLocalizedString("Добавлено максимальное количество фотографий", comment: "")
        }
        return images.isEmpty
            ? String(format: NSLocalizedString("Добавьте фото, максимум %lld", comment: ""), selectionLimit)
            : String(format: NSLocalizedString("Можно добавить ещё %lld", comment: ""), selectionLimit)
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
    PickedImagesGrid(
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
    PickedImagesGrid(
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
