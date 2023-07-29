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
    private let screenWidth = UIScreen.main.bounds.size.width

    @State private var fullscreenImageInfo: PhotoDetailScreen.Model?

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
        SectionView(headerWithPadding: "Фотографии", mode: .regular) {
            LazyVGrid(
                columns: .init(
                    repeating: .init(
                        .flexible(minimum: screenWidth * 0.282),
                        spacing: 2
                    ),
                    count: columns
                ),
                spacing: 2
            ) {
                ForEach(photos) { photo in
                    if columns == 1 {
                        makeCell(with: photo)
                            .frame(height: 172)
                    } else {
                        GeometryReader { geo in
                            makeCell(with: photo)
                                .frame(height: geo.size.width)
                        }
                        .clipped()
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(4)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .insideCardBackground()
            .fullScreenCover(item: $fullscreenImageInfo) {
                fullscreenImageInfo = nil
            } content: { model in
                PhotoDetailScreen(
                    model: model,
                    canDelete: canDelete,
                    reportPhotoClbk: reportPhotoClbk,
                    deletePhotoClbk: deletePhotoClbk
                )
            }
        }
    }
}

private extension PhotoSectionView {
    /// Количество столбцов в сетке с фотографиями
    var columns: Int {
        switch photos.count {
        case 1: return 1
        case 2: return 2
        default: return 3
        }
    }

    func makeCell(with photo: Photo) -> some View {
        ResizableCachedImage(
            url: photo.imageURL,
            didTapImage: { uiImage in
                fullscreenImageInfo = .init(uiImage: uiImage, id: photo.id)
            }
        )
        .scaledToFill()
    }
}

#if DEBUG
struct PhotoSectionView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PhotoSectionView(
                with: Photo.makePreviewList(count: 8),
                canDelete: true,
                reportClbk: {},
                deleteClbk: { _ in }
            )
            .padding()
            .background(Color.swBackground)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
