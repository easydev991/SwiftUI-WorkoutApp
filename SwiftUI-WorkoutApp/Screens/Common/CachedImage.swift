import SwiftUI
import CachedAcyncImage

struct CachedImage: View {
    let url: URL?
    var mode = Mode.userListItem

    var body: some View {
        CachedAsyncImage(url: url) { uiImage in
            Image(uiImage: uiImage).resizable()
        } placeholder: {
            RoundedDefaultImage(size: mode.size)
        }
        .scaledToFit()
        .cornerRadius(8)
        .frame(width: mode.size.width, height: mode.size.height)
    }
}

extension CachedImage {
    enum Mode {
        case userListItem, groundListItem, eventListItem,
             dialogListItem, genericListItem, journalEntry,
             profileAvatar, eventPhoto, groundPhoto
        var size: CGSize {
            switch self {
            case .userListItem:
                return .init(width: 36, height: 36)
            case .groundListItem, .eventListItem, .dialogListItem:
                return .init(width: 60, height: 60)
            case .genericListItem, .journalEntry:
                return .init(width: 24, height: 24)
            case .profileAvatar, .eventPhoto, .groundPhoto:
                return .init(width: 300, height: 250)
            }
        }
    }
}

#if DEBUG
struct SmallProfileCacheImageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CachedImage(url: .init(string: "https://workout.su/img/avatar_default.jpg")!)
            CachedImage(
                url: .init(string: "https://workout.su/img/avatar_default.jpg")!,
                mode: .profileAvatar
            )
        }
        .previewDevice("iPhone 13 mini")
        .previewLayout(.sizeThatFits)
    }
}
#endif
