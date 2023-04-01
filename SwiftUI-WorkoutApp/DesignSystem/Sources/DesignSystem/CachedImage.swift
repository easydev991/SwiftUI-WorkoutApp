import CachedAsyncImage991
import SwiftUI

public struct CachedImage: View {
    private let url: URL?
    private let mode: Mode
    private let didTapImage: ((UIImage) -> Void)?

    public init(
        url: URL?,
        mode: Mode = .userListItem,
        didTapImage: ((UIImage) -> Void)? = nil
    ) {
        self.url = url
        self.mode = mode
        self.didTapImage = didTapImage
    }

    public var body: some View {
        CachedAsyncImage991(url: url) { uiImage in
            Image(uiImage: uiImage)
                .resizable()
                .onTapGesture { didTapImage?(uiImage) }
        } placeholder: {
            RoundedDefaultImage(size: mode.size)
        }
        .scaledToFit()
        .cornerRadius(8)
        .frame(width: mode.size.width, height: mode.size.height)
    }
}

public extension CachedImage {
    enum Mode: CaseIterable {
        case userListItem, groundListItem, eventListItem,
             dialogListItem, genericListItem, journalEntry,
             profileAvatar, eventPhoto, groundPhoto, gridPhoto
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
            case .gridPhoto:
                return .init(width: 150, height: 150)
            }
        }
    }
}

#if DEBUG
struct SmallProfileCacheImageView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            ForEach(
                CachedImage.Mode.allCases,
                id:
                \.self
            ) { mode in
                CachedImage(
                    url: .init(string: "https://workout.su/img/avatar_default.jpg")!,
                    mode: mode
                )
            }
        }
    }
}
#endif
