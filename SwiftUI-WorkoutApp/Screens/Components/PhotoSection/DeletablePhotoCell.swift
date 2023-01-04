import SwiftUI

struct DeletablePhotoCell: View {
    @EnvironmentObject private var network: CheckNetworkService
    let photo: Photo
    let canDelete: Bool
    var onTapClbk: (UIImage) -> Void
    var deleteClbk: (Photo) -> Void

    var body: some View {
        CacheAsyncImage(url: photo.imageURL) { uiImage in
            Image(uiImage: uiImage)
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture { onTapClbk(uiImage) }
        }
        .scaledToFit()
        .cornerRadius(8)
        .overlay(alignment: .topTrailing) {
            menuButton
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
                .font(.title2)
                .foregroundColor(.gray)
        }
        .padding(8)
        .onTapGesture { hapticFeedback(.rigid) }
        .opacity(showMenuButton ? 1 : .zero)
    }

    var showMenuButton: Bool {
        canDelete && network.isConnected
    }
}

struct DeletablePhotoCell_Previews: PreviewProvider {
    static var previews: some View {
        DeletablePhotoCell(
            photo: .mock,
            canDelete: true,
            onTapClbk: {_ in},
            deleteClbk: {_ in}
        )
        .environmentObject(CheckNetworkService())
        .previewLayout(.sizeThatFits)
    }
}
