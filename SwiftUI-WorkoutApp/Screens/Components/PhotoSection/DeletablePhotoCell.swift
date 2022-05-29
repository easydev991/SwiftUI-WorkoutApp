import SwiftUI

struct DeletablePhotoCell: View {
    let photo: Photo
    let canDelete: Bool
    var deleteClbk: (Photo) -> Void

    var body: some View {
        CacheAsyncImage(url: photo.imageURL) {
            Image(uiImage: $0).resizable()
        }
        .scaledToFill()
        .cornerRadius(8)
        .overlay(alignment: .topTrailing) {
            menuButton
                .opacity(canDelete ? 1 : .zero)
        }
    }
}

private extension DeletablePhotoCell {
    var menuButton: some View {
        Menu {
            Button(role: .destructive) {
                deleteClbk(photo)
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.title)
        }
        .padding()
        .onTapGesture { hapticFeedback(.rigid) }
    }
}

struct DeletablePhotoCell_Previews: PreviewProvider {
    static var previews: some View {
        DeletablePhotoCell(photo: .mock, canDelete: true, deleteClbk: {_ in})
    }
}
