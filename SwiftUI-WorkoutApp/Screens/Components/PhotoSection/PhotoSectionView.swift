import SwiftUI

/// Галерея с фотографиями
struct PhotoSectionView: View {
    private let items: [Photo]
    private let canDelete: Bool
    private let deletePhotoClbk: (Photo) -> Void
    @State private var fullscreenImage: UIImage?
    @State private var columns: Int

    init(
        with photos: [Photo],
        canDelete: Bool,
        deleteClbk: @escaping (Photo) -> Void
    ) {
        items = photos
        self.columns = photos.count == 1 ? 1 : 2
        self.canDelete = canDelete
        deletePhotoClbk = deleteClbk
    }

    var body: some View {
        Section("Фотографии") {
            ScrollView {
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
                            onTapClbk: openImage,
                            deleteClbk: deletePhotoClbk
                        )
                    }
                }
                .fullScreenCover(item: $fullscreenImage) {
                    fullscreenImage = nil
                } content: {
                    FullScreenImageSheet(image: $0)
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

struct PhotoSectionView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            PhotoSectionView(with: [.mock, .mock, .mock], canDelete: true, deleteClbk: {_ in})
        }
    }
}
