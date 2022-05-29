import SwiftUI

/// Галерея с фотографиями
struct PhotoSectionView: View {
    @State private var showAll = false
    private let items: [Photo]

    init(with photos: [Photo]) {
        items = photos
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
            showAll.toggle()
        } label: {
            ButtonInFormLabel(title: "Показать все")
        }
        .sheet(isPresented: $showAll) {
            photosSheet
        }
    }

    var photosSheet: some View {
        VStack(spacing: .zero) {
            HeaderForSheet(title: "Фотографии") {
                showAll.toggle()
            }
            ScrollView {
                LazyVStack {
                    ForEach(items) {
                        CacheAsyncImage(url: $0.imageURL) {
                            Image(uiImage: $0).resizable()
                        }
                        .scaledToFill()
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
}

struct PhotosCollection_Previews: PreviewProvider {
    static var previews: some View {
        PhotoSectionView(with: [.mock, .mock, .mock])
    }
}
