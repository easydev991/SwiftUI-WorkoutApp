import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels

struct PhotoSectionCell: View {
    let photo: Photo
    let canDelete: Bool
    let reportClbk: () -> Void
    let onTapClbk: (UIImage) -> Void
    let deleteClbk: (Int) -> Void

    var body: some View {
        ResizableCachedImage(
            url: photo.imageURL,
            didTapImage: onTapClbk
        )
        .scaledToFill()
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
                    Label("Пожаловаться", systemImage: Icons.Button.exclamation.rawValue)
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.title2)
                .foregroundColor(.gray)
        }
        .padding(8)
        .onTapGesture { hapticFeedback(.rigid) }
//        .opacity(network.isConnected ? 1 : 0)
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
//        .environmentObject(NetworkStatus())
            .previewLayout(.sizeThatFits)
    }
}
#endif
