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
                .scaledToFill()
                .onTapGesture { didTapImage?(uiImage) }
        } placeholder: {
            RoundedDefaultImage(size: mode.size)
        }
        .frame(width: mode.size.width, height: mode.size.height)
        .clipped()
        .cornerRadius(12)
    }
}

public extension CachedImage {
    enum Mode: CaseIterable {
        case dialogListItem, genericListItem, journalEntry, eventPhoto, groundPhoto, gridPhoto
        /// Фото в списке площадок
        case groundListItem
        /// Фото в списке мероприятий
        case eventListItem
        /// Аватар автора комментария
        case commentAvatar
        /// Аватар автора дневника/записи в дневнике
        case journalAvatar
        /// Аватар пользователя в списке людей/заявок в друзья
        case userListItem
        /// Аватар пользователя в окне чата
        case avatarInDialogView
        /// Аватар пользователя в профиле
        case profileAvatar

        var size: CGSize {
            switch self {
            case .userListItem, .journalAvatar:
                return .init(width: 42, height: 42)
            case .groundListItem, .eventListItem, .dialogListItem:
                return .init(width: 74, height: 74)
            case .genericListItem, .journalEntry:
                return .init(width: 24, height: 24)
            case .eventPhoto, .groundPhoto:
                return .init(width: 300, height: 250)
            case .gridPhoto:
                return .init(width: 150, height: 150)
            case .commentAvatar:
                return .init(width: 40, height: 40)
            case .avatarInDialogView:
                return .init(width: 32, height: 32)
            case .profileAvatar:
                return .init(width: 150, height: 150)
            }
        }
    }
}

#if DEBUG
struct SmallProfileCacheImageView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            ForEach(CachedImage.Mode.allCases, id: \.self) { mode in
                CachedImage(
                    url: .init(string: "https://workout.su/img/avatar_default.jpg")!,
                    mode: mode
                )
            }
        }
    }
}
#endif
