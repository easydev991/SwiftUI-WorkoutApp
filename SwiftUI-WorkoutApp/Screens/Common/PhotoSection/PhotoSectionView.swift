import SwiftUI

/// Галерея с фотографиями
struct PhotoSectionView: View {
    private let photos: [Photo]
    /// `true` - есть доступ на удаление фото, `false` - нет доступа
    ///
    /// Если пользователь авторизован и является автором фотографии, у него есть права на ее удаление
    private let canDelete: Bool
    private let reportPhotoClbk: (Photo) -> Void
    private let deletePhotoClbk: (Photo) -> Void
    /// Количество столбцов в сетке с фотографиями
    private var columns: Int { photos.count > 1 ? 2 : 1 }
    @State private var fullscreenImage: UIImage?

    init(
        with photos: [Photo],
        canDelete: Bool,
        reportClbk: @escaping (Photo) -> Void,
        deleteClbk: @escaping (Photo) -> Void
    ) {
        self.photos = photos
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
                ForEach(photos) { photo in
                    PhotoSectionCell(
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
