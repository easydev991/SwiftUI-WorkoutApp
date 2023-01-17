import SwiftUI

/// Галерея с фотографиями
struct PhotoSectionView: View {
    private let items: [Photo]
    private let canDelete: Bool
    private let reportPhotoClbk: (Photo) -> Void
    private let deletePhotoClbk: (Photo) -> Void
    @State private var fullscreenImage: UIImage?
    @State private var columns: Int

    init(
        with photos: [Photo],
        canDelete: Bool,
        reportClbk: @escaping (Photo) -> Void,
        deleteClbk: @escaping (Photo) -> Void
    ) {
        items = photos
        self.columns = photos.count == 1 ? 1 : 2
        self.canDelete = canDelete
        reportPhotoClbk = reportClbk
        deletePhotoClbk = deleteClbk
    }

    var body: some View {
        Section("Фотографии") {
            LazyVGrid(
                columns: .init(
                    repeating: .init(
                        .flexible(minimum: 150, maximum: .infinity),
                        spacing: 12,
                        alignment: .top
                    ),
                    count: columns
                ),
                spacing: 12
            ) {
                ForEach(items) { photo in
                    DeletablePhotoCell(
                        photo: photo,
                        canDelete: canDelete,
                        reportClbk: reportPhotoClbk,
                        onTapClbk: openImage,
                        deleteClbk: deletePhotoClbk
                    )
                }
            }
            .fullScreenCover(item: $fullscreenImage) {
                fullscreenImage = nil
            } content: { image in
                ContentInSheet(title: "Фото") {
                    ImageDetailView(image: image)
                }
            }
        }
    }
}

private extension PhotoSectionView {
    func openImage(_ image: UIImage) {
        fullscreenImage = image
    }
}

#if DEBUG
struct PhotoSectionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PhotoSectionView(
                with: [.preview, .preview, .preview],
                canDelete: true,
                reportClbk: { _ in },
                deleteClbk: { _ in }
            )
        }
    }
}
#endif
