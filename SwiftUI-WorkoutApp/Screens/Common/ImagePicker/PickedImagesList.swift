import DesignSystem
import ImagePicker
import SwiftUI

struct PickedImagesGrid: View {
    @Binding var images: [UIImage]
    @Binding var showImagePicker: Bool
    /// Сколько еще можно выбрать фотографий
    let selectionLimit: Int
    /// Обработать добавление лишних фотографий
    let processExtraImages: () -> Void

    var body: some View {
        SectionView(header: header, mode: .regular) {
            VStack(alignment: .leading, spacing: 6) {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.swMainText)
                    .multilineTextAlignment(.leading)
                LazyVGrid(
                    columns: .init(
                        repeating: .init(
                            .flexible(minimum: 100), spacing: 11
                        ),
                        count: 3
                    ),
                    spacing: 12
                ) {
                    ForEach(Array(zip(images.indices, images)), id: \.0) { index, image in
                        HStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 100)
                                .cornerRadius(8)
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Фото № \(index + 1)")
                                Text("Свайпни для удаления")
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deletePhoto)
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
