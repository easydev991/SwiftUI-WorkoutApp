import SWDesignSystem
import SwiftUI
import SWModels

/// Галерея с фотографиями
@MainActor
struct PhotoSectionView: View {
    private var screenWidth: CGFloat { UIScreen.main.bounds.size.width }
    private let photos: [Photo]
    /// `true` - есть доступ на удаление фото, `false` - нет доступа
    ///
    /// Если пользователь авторизован и является автором фотографии, у него есть права на ее удаление
    private let canDelete: Bool
    private let reportPhotoClbk: () -> Void
    private let deletePhotoClbk: (Int) -> Void
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
            ZStack {
                if columns == 1 {
                    makeSingleView(with: photos[0])
                } else {
                    gridView
                }
            }
            .animation(.default, value: photos.count == 1)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .insideCardBackground()
            .fullScreenCover(item: $fullscreenImageInfo) {
                fullscreenImageInfo = nil
            } content: { model in
                PhotoDetailScreen(
                    model: model,
                    canDelete: canDelete,
                    reportPhotoClbk: reportPhotoClbk,
                    deletePhotoClbk: {
                        fullscreenImageInfo = nil
                        deletePhotoClbk($0)
                    }
                )
            }
        }
    }
}

private extension PhotoSectionView {
    /// Количество столбцов в сетке с фотографиями
    var columns: Int {
        switch photos.count {
        case 1: 1
        case 2: 2
        default: 3
        }
    }

    var gridView: some View {
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
                makeSingleView(with: photo)
                    .cornerRadius(4)
            }
        }
    }

    /// Картинка после применения `clipped` и `contentShape`
    /// все еще перекрывает другие UI-элементы и не дает их нажимать,
    /// поэтому используем `GeometryReader` + `scaledToFit`
    func makeSingleView(with photo: Photo) -> some View {
        GeometryReader { geo in
            ResizableCachedImage(
                url: photo.imageURL,
                didTapImage: { uiImage in
                    fullscreenImageInfo = .init(uiImage: uiImage, id: photo.serverId)
                }
            )
            .scaledToFill()
            .frame(height: geo.size.width)
            .clipped()
            .contentShape(.rect)
        }
        .scaledToFit()
    }
}

#if DEBUG
#Preview {
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
}
#endif
