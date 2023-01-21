import SwiftUI
import CachedAcyncImage
import NetworkStatus

struct PhotoSectionCell: View {
    @EnvironmentObject private var network: NetworkStatus
    let photo: Photo
    let canDelete: Bool
    let reportClbk: (Photo) -> Void
    var onTapClbk: (UIImage) -> Void
    var deleteClbk: (Photo) -> Void

    var body: some View {
        CachedAsyncImage(url: photo.imageURL) { uiImage in
            Image(uiImage: uiImage)
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture { onTapClbk(uiImage) }
        } placeholder: {
            RoundedDefaultImage(size: CachedImage.Mode.groundListItem.size)
        }
        .scaledToFit()
        .cornerRadius(8)
        .overlay(alignment: .topTrailing) { menuButton }
    }
}

private extension PhotoSectionCell {
    var menuButton: some View {
        Menu {
            if canDelete {
                Button(role: .destructive) {
                    deleteClbk(photo)
                } label: {
                    Label("Удалить", systemImage: "trash")
                }
            } else {
                Button(role: .destructive) {
                    reportClbk(photo)
                } label: {
                    Label("Пожаловаться", systemImage: "exclamationmark.triangle")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.title2)
                .foregroundColor(.gray)
        }
        .padding(8)
        .onTapGesture { hapticFeedback(.rigid) }
        .opacity(network.isConnected ? 1 : 0)
    }
}

#if DEBUG
struct PhotoSectionCell_Previews: PreviewProvider {
    static var previews: some View {
        PhotoSectionCell(
            photo: .preview,
            canDelete: true,
            reportClbk: { _ in },
            onTapClbk: { _ in },
            deleteClbk: { _ in }
        )
        .environmentObject(NetworkStatus())
        .previewLayout(.sizeThatFits)
    }
}
#endif
