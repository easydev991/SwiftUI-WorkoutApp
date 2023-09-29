import CachedAsyncImage991
import SwiftUI

/// Вьюшка с комментарием (в списке комментариев)
public struct CommentRowView: View {
    private let avatarURL: URL?
    private let userName: String
    private let dateText: String
    private let bodyText: String
    private let isCommentByMainUser: Bool
    private let isNetworkConnected: Bool
    private let reportAction: () -> Void
    private let editAction: () -> Void
    private let deleteAction: () -> Void

    public init(
        avatarURL: URL?,
        userName: String,
        dateText: String,
        bodyText: String,
        isCommentByMainUser: Bool,
        isNetworkConnected: Bool,
        reportAction: @escaping () -> Void,
        editAction: @escaping () -> Void,
        deleteAction: @escaping () -> Void
    ) {
        self.avatarURL = avatarURL
        self.userName = userName
        self.dateText = dateText
        self.bodyText = bodyText
        self.isCommentByMainUser = isCommentByMainUser
        self.isNetworkConnected = isNetworkConnected
        self.reportAction = reportAction
        self.editAction = editAction
        self.deleteAction = deleteAction
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
                if isNetworkConnected {
                    menuButton
                }
            }
            bodyTextView
        }
        .padding(12)
    }
}

private extension CommentRowView {
    var leadingImage: some View {
        CachedImage(url: avatarURL, mode: .commentAvatar)
            .borderedClipshape()
    }

    var menuButton: some View {
        Menu {
            if isCommentByMainUser {
                Button(action: editAction) {
                    Label("Изменить", systemImage: "rectangle.and.pencil.and.ellipsis")
                }
                Button(role: .destructive, action: deleteAction) {
                    Label("Удалить", systemImage: "trash")
                }
            } else {
                Button(role: .destructive, action: reportAction) {
                    Label("Пожаловаться", systemImage: Icons.Regular.exclamation.rawValue)
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .frame(width: 30, height: 30, alignment: .topTrailing)
                .foregroundColor(.swSmallElements)
        }
        .onTapGesture { hapticFeedback(.rigid) }
    }

    var userNameView: some View {
        Text(userName)
            .foregroundColor(.swMainText)
            .font(.headline)
    }

    var dateTextView: some View {
        Text(dateText)
            .foregroundColor(.swSmallElements)
            .font(.caption2)
    }

    var bodyTextView: some View {
        Text(.init(bodyText))
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(.swMainText)
            .tint(.swAccent)
            .textSelection(.enabled)
            .multilineTextAlignment(.leading)
    }
}

#if DEBUG
#Preview {
    CommentRowView(
        avatarURL: .init(string: "https://workout.su/uploads/avatars/2019/10/2019-10-07-01-10-08-yow.jpg")!,
        userName: "Kahar",
        dateText: "21 мая 2023",
        bodyText: "Классная площадка, часто тренируюсь здесь с друзьями",
        isCommentByMainUser: false,
        isNetworkConnected: true,
        reportAction: {},
        editAction: {},
        deleteAction: {}
    )
    .padding()
    .previewLayout(.sizeThatFits)
}
#endif
