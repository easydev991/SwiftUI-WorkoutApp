import CachedAsyncImage991
import SwiftUI

public struct CachedImage: View {
    private let url: URL?
    private let mode: Mode
    private let cornerRadius: CGFloat
    private let didTapImage: ((UIImage) -> Void)?

    public init(
        url: URL?,
        mode: Mode = .userListItem,
        cornerRadius: CGFloat = 12,
        didTapImage: ((UIImage) -> Void)? = nil
    ) {
        self.url = url
        self.mode = mode
        self.cornerRadius = cornerRadius
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
        .cornerRadius(cornerRadius)
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
                .init(width: 42, height: 42)
            case .groundListItem, .eventListItem, .dialogListItem:
                .init(width: 74, height: 74)
            case .genericListItem, .journalEntry:
                .init(width: 24, height: 24)
            case .eventPhoto, .groundPhoto:
                .init(width: 300, height: 250)
            case .gridPhoto:
                .init(width: 150, height: 150)
            case .commentAvatar:
                .init(width: 40, height: 40)
            case .avatarInDialogView:
                .init(width: 32, height: 32)
            case .profileAvatar:
                .init(width: 150, height: 150)
            }
        }
    }
}

#if DEBUG
#Preview {
    ScrollView {
        ForEach(CachedImage.Mode.allCases, id: \.self) { mode in
            CachedImage(
                url: .init(string: "https://workout.su/img/avatar_default.jpg")!,
                mode: mode
            )
        }
    }
}
#endif
