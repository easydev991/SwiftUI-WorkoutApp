import SwiftUI

struct DeletablePhotoCell: View {
    @EnvironmentObject private var network: CheckNetworkService
    let photo: Photo
    let canDelete: Bool
    let reportClbk: (Photo) -> Void
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
struct DeletablePhotoCell_Previews: PreviewProvider {
    static var previews: some View {
        DeletablePhotoCell(
            photo: .preview,
            canDelete: true,
            reportClbk: { _ in },
            onTapClbk: { _ in },
            deleteClbk: { _ in }
        )
        .environmentObject(CheckNetworkService())
        .previewLayout(.sizeThatFits)
    }
}
#endif
