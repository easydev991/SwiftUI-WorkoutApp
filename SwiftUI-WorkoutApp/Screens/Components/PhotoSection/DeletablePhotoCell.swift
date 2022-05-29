import SwiftUI

struct DeletablePhotoCell: View {
    @EnvironmentObject private var network: CheckNetworkService
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
                .opacity(showMenuButton ? 1 : .zero)
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

    var showMenuButton: Bool {
        canDelete && network.isConnected
    }
}

struct DeletablePhotoCell_Previews: PreviewProvider {
    static var previews: some View {
        DeletablePhotoCell(photo: .mock, canDelete: true, deleteClbk: {_ in})
            .environmentObject(CheckNetworkService())
    }
}
