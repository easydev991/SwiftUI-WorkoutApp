import SwiftUI

/// Галерея с фотографиями
struct PhotosGallery: View {
    @State private var showAll = false
    let items: [Photo]

    var body: some View {
        Section("Фотографии") {
            previewImage
            if items.count > 1 {
                showAllButton
            }
        }
    }
}

private extension PhotosGallery {
    var previewImage: some View {
        CacheAsyncImage(url: items.first?.imageURL) {
            Image(uiImage: $0).resizable()
        }
        .scaledToFill()
        .frame(maxHeight: 150)
        .cornerRadius(8)
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
            List {
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

struct PhotosCollection_Previews: PreviewProvider {
    static var previews: some View {
        PhotosGallery(items: [.mock, .mock, .mock])
    }
}
