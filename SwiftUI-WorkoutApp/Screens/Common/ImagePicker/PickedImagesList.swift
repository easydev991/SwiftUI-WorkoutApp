import DesignSystem
import ImagePicker
import SwiftUI

struct PickedImagesGrid: View {
    private let screenWidth = UIScreen.main.bounds.size.width
    private var imagesArray: [PickedPhotoView.Model] {
        var realImages: [PickedPhotoView.Model] = images.map {
            .image(.init(uiImage: $0))
        }
        if selectionLimit > 0 {
            realImages.append(.addImageButton)
        }
        return realImages
    }
    @Binding var images: [UIImage]
    @Binding var showImagePicker: Bool
    /// Сколько еще можно выбрать фотографий
    let selectionLimit: Int
    /// Обработать добавление лишних фотографий
    let processExtraImages: () -> Void

    var body: some View {
        SectionView(header: header, mode: .regular) {
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
                            PickedPhotoView(model: model) // добавить кнопку для удаления фотографии (deletePhoto)
                                .scaledToFill()
                                .frame(height: geo.size.width)
                                .onTapGesture {
                                    if case .addImageButton = model {
                                        showImagePicker.toggle()
                                    }
                                }
                        }
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            processExtraImages()
        } content: {
            ImagePicker(
                pickedImages: $images,
                selectionLimit: selectionLimit,
                compressionQuality: .zero
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
        let selectionLimitString = String.localizedStringWithFormat(
            NSLocalizedString("photosCount", comment: ""),
            selectionLimit
        )
        return images.count == 0
        ? "Добавьте фото площадки, максимум \(selectionLimit)"
        : "Можно добавить ещё \(selectionLimitString)"
    }
    
    func deletePhoto(at offsets: IndexSet) {
        if let index = offsets.first {
            images.remove(at: index)
        }
    }
}

#if DEBUG
struct PickedImagesGrid_Previews: PreviewProvider {
    static var previews: some View {
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
}
#endif
