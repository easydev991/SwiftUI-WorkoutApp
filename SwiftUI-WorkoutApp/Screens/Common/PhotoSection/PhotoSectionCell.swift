import CachedAcyncImage
import NetworkStatus
import SwiftUI
import SWModels

struct PhotoSectionCell: View {
    @EnvironmentObject private var network: NetworkStatus
    let photo: Photo
    let canDelete: Bool
    let reportClbk: () -> Void
    let onTapClbk: (UIImage) -> Void
    let deleteClbk: (Int) -> Void

    var body: some View {
        CachedAsyncImage(url: photo.imageURL) { uiImage in
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .onTapGesture { onTapClbk(uiImage) }
        } placeholder: {
            RoundedDefaultImage(size: CachedImage.Mode.gridPhoto.size)
        }
        .cornerRadius(8)
        .overlay(alignment: .topTrailing) { menuButton }
    }
}

private extension PhotoSectionCell {
    var menuButton: some View {
        Menu {
            if canDelete {
                Button(role: .destructive) {
                    deleteClbk(photo.id)
                } label: {
                    Label("Удалить", systemImage: "trash")
                }
            } else {
                Button(role: .destructive, action: reportClbk) {
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
            reportClbk: {},
            onTapClbk: { _ in },
            deleteClbk: { _ in }
        )
        .environmentObject(NetworkStatus())
        .previewLayout(.sizeThatFits)
    }
}
#endif
