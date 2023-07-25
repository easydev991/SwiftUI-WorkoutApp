import DesignSystem
import SwiftUI
import SWModels

/// Галерея с фотографиями
struct PhotoSectionView: View {
    private let photos: [Photo]
    /// `true` - есть доступ на удаление фото, `false` - нет доступа
    ///
    /// Если пользователь авторизован и является автором фотографии, у него есть права на ее удаление
    private let canDelete: Bool
    private let reportPhotoClbk: () -> Void
    private let deletePhotoClbk: (Int) -> Void
    /// Количество столбцов в сетке с фотографиями
    private var columns: Int {
        switch photos.count {
        case 1: return 1
        case 2: return 2
        default: return 3
        }
    }
    @State private var fullscreenImage: UIImage?

    init(
        with photos: [Photo],
        canDelete: Bool,
        reportClbk: @escaping () -> Void,
        deleteClbk: @escaping (Int) -> Void
    ) {
        self.photos = photos
        self.canDelete = canDelete
        self.reportPhotoClbk = reportClbk
        self.deletePhotoClbk = deleteClbk
    }

    var body: some View {
        SectionView(header: "Фотографии", mode: .regular) {
            LazyVGrid(
                columns: .init(
                    repeating: .init(
                        .flexible(minimum: 110, maximum: .infinity),
                        spacing: 2,
                        alignment: .top
                    ),
                    count: columns
                ),
                spacing: 2
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
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .insideCardBackground()
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
        VStack(spacing: 20) {
            PhotoSectionView(
                with: [.preview],
                canDelete: true,
                reportClbk: {},
                deleteClbk: { _ in }
            )
            .padding()
            PhotoSectionView(
                with: Photo.makePreviewList(count: 2),
                canDelete: true,
                reportClbk: {},
                deleteClbk: { _ in }
            )
            .padding()
            PhotoSectionView(
                with: Photo.makePreviewList(count: 3),
                canDelete: true,
                reportClbk: {},
                deleteClbk: { _ in }
            )
            .padding()
            .background(Color.swBackground)
            .environment(\.colorScheme, .dark)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
