import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels

struct PhotoDetailScreen: View {
    @EnvironmentObject private var network: NetworkStatus
    @Environment(\.dismiss) private var dismiss
    let image: UIImage
    
    var body: some View {
        ImageDetailView(image: image)
            .background(Color.swBackground)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    deleteButton
                        .opacity(network.isConnected ? 1 : 0)
                }
            }
    }
}

private extension PhotoDetailScreen {
    var deleteButton: some View {
        Button(role: .destructive) {
//            deleteClbk(photo.id)
        } label: {
            Image(systemName: Icons.Button.trash.rawValue)
        }
    }
    
    var reportButton: some View {
        Button(role: .destructive, action: {}) {
            Image(systemName: Icons.Button.exclamation.rawValue)
        }
    }
}

#if DEBUG
struct PhotoDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        PhotoDetailScreen(image: .init())
            .environmentObject(NetworkStatus())
    }
}
#endif
