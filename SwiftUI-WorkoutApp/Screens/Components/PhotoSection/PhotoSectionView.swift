import SwiftUI

/// Галерея с фотографиями
struct PhotoSectionView: View {
    @State private var showAllPhotos = false
    private let items: [Photo]
    private let canDelete: Bool
    private let deletePhotoClbk: (Photo) -> Void

    init(
        with photos: [Photo],
        canDelete: Bool,
        deleteClbk: @escaping (Photo) -> Void
    ) {
        items = photos
        self.canDelete = canDelete
        deletePhotoClbk = deleteClbk
    }

    var body: some View {
        Section("Фотографии") {
            previewImage
            if items.count > 1 {
                showAllButton
            }
        }
    }
}

private extension PhotoSectionView {
    var previewImage: some View {
        HStack {
            Spacer()
            CacheImageView(url: items.first?.imageURL, mode: .eventPhoto)
            Spacer()
        }
    }

    var showAllButton: some View {
        Button {
            showAllPhotos.toggle()
        } label: {
            ButtonInFormLabel(title: "Показать все")
        }
        .sheet(isPresented: $showAllPhotos) {
            photosSheet
        }
    }

    var photosSheet: some View {
        VStack(spacing: .zero) {
            HeaderForSheet(title: "Фотографии") {
                showAllPhotos.toggle()
            }
            ScrollView {
                LazyVStack {
                    ForEach(items) { photo in
                        DeletablePhotoCell(
                            photo: photo,
                            canDelete: canDelete,
                            deleteClbk: deleteAction
                        )
                    }
                }
            }
        }
    }

    func deleteAction(photo: Photo) {
        showAllPhotos.toggle()
        deletePhotoClbk(photo)
    }
}

struct PhotosCollection_Previews: PreviewProvider {
    static var previews: some View {
        PhotoSectionView(with: [.mock, .mock, .mock], canDelete: true, deleteClbk: {_ in})
    }
}
