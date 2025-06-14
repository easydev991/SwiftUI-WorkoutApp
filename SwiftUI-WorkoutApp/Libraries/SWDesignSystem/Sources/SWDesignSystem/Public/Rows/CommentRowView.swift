import SwiftUI

/// Вьюшка с комментарием (в списке комментариев)
public struct CommentRowView: View {
    private let avatarURL: URL?
    private let userName: String
    private let dateText: String
    private let bodyText: String
    private let isCommentByMainUser: Bool
    private let isNetworkConnected: Bool
    private let action: (Action) -> Void

    public init(
        avatarURL: URL?,
        userName: String,
        dateText: String,
        bodyText: String,
        isCommentByMainUser: Bool,
        isNetworkConnected: Bool,
        action: @escaping (Action) -> Void
    ) {
        self.avatarURL = avatarURL
        self.userName = userName
        self.dateText = dateText
        self.bodyText = bodyText
        self.isCommentByMainUser = isCommentByMainUser
        self.isNetworkConnected = isNetworkConnected
        self.action = action
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                leadingImage
                VStack(alignment: .leading, spacing: 6) {
                    userNameView
                    dateTextView
                }
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
                .onTapGesture { action(.openProfile) }
                if isNetworkConnected {
                    menuButton
                }
            }
            bodyTextView
        }
        .padding(12)
    }
}

public extension CommentRowView {
    enum Action {
        /// Пожаловаться
        case report
        /// Редактировать
        case edit
        /// Удалить
        case delete
        /// Открыть профиль автора комментария
        case openProfile
    }
}

private extension CommentRowView {
    var leadingImage: some View {
        CachedImage(
            url: avatarURL,
            mode: .commentAvatar,
            didTapImage: { _ in action(.openProfile) }
        )
        .borderedCircleClipShape()
    }

    var menuButton: some View {
        Menu {
            if isCommentByMainUser {
                Button(action: { action(.edit) }) {
                    Label {
                        Text("Edit", bundle: .module)
                    } icon: {
                        Image(systemName: Icons.Regular.pencil.rawValue)
                    }
                }
                Button(role: .destructive, action: { action(.delete) }) {
                    Label {
                        Text("Delete", bundle: .module)
                    } icon: {
                        Image(systemName: Icons.Regular.trash.rawValue)
                    }
                }
            } else {
                Button(role: .destructive, action: { action(.report) }) {
                    Label {
                        Text("Report", bundle: .module)
                    } icon: {
                        Image(systemName: Icons.Regular.exclamation.rawValue)
                    }
                }
            }
        } label: {
            Image(systemName: Icons.Regular.ellipsis.rawValue)
                .frame(width: 30, height: 30, alignment: .topTrailing)
                .foregroundStyle(Color.swSmallElements)
        }
        .onTapGesture { hapticFeedback(.rigid) }
    }

    var userNameView: some View {
        Text(userName)
            .foregroundStyle(Color.swMainText)
            .font(.headline)
    }

    var dateTextView: some View {
        Text(dateText)
            .foregroundStyle(Color.swSmallElements)
            .font(.caption2)
    }

    var bodyTextView: some View {
        Text(.init(bodyText))
            .fixedSize(horizontal: false, vertical: true)
            .foregroundStyle(Color.swMainText)
            .tint(.swAccent)
            .textSelection(.enabled)
            .multilineTextAlignment(.leading)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 20) {
        CommentRowView(
            avatarURL: .init(string: "https://workout.su/uploads/avatars/2019/10/2019-10-07-01-10-08-yow.jpg")!,
            userName: "Kahar",
            dateText: "21 мая 2023",
            bodyText: "Классная площадка, часто тренируюсь здесь с друзьями",
            isCommentByMainUser: false,
            isNetworkConnected: true,
            action: { option in
                print("action: \(option)")
            }
        )
        CommentRowView(
            avatarURL: .init(string: "https://workout.su/uploads/avatars/2019/10/2019-10-07-01-10-08-yow.jpg")!,
            userName: "Kahar",
            dateText: "21 мая 2023",
            bodyText: "Классная площадка, часто тренируюсь здесь с друзьями",
            isCommentByMainUser: true,
            isNetworkConnected: true,
            action: { option in
                print("action: \(option)")
            }
        )
    }
}
#endif
