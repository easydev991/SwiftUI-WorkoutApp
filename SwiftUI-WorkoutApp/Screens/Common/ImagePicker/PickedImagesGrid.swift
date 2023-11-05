import ImagePicker
import SWDesignSystem
import SwiftUI

struct PickedImagesGrid: View {
    private let screenWidth = UIScreen.main.bounds.size.width
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
    let processExtraImages: () -> Void

    var body: some View {
        SectionView(header: .init(header), mode: .regular) {
            VStack(alignment: .leading, spacing: 12) {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.swMainText)
                    .multilineTextAlignment(.leading)
                LazyVGrid(
                    columns: .init(
                        repeating: .init(
                            .flexible(minimum: screenWidth * 0.287), spacing: 11
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
        if images.isEmpty {
            String(format: NSLocalizedString("Добавьте фото, максимум %lld", comment: ""), selectionLimit)
        } else {
            selectionLimit > 0
                ? String(format: NSLocalizedString("Можно добавить ещё %lld", comment: ""), selectionLimit)
                : NSLocalizedString("Добавлено максимальное количество фотографий", comment: "")
        }
    }

    func deletePhoto(at index: Int) {
        images.remove(at: index)
        fullscreenImageInfo = nil
    }
}

#if DEBUG
#Preview {
    PickedImagesGrid(
        images: .constant([
            .init(systemName: "person")!,
            .init(systemName: "book")!
        ]),
        showImagePicker: .constant(false),
        selectionLimit: 5,
        processExtraImages: {}
    )
}
#endif
