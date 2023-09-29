import SwiftUI

public struct DialogRowView: View {
    private let model: Model

    public init(model: Model) {
        self.model = model
    }

    public var body: some View {
        HStack(spacing: 12) {
            leadingImage
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 12) {
                    authorNameView
                    dateTextView
                }
                HStack(spacing: 12) {
                    messageView
                    if model.hasUnreadMessages {
                        BadgeView(value: model.unreadCount)
                    }
                }
            }
            .lineLimit(1)
        }
    }
}

public extension DialogRowView {
    struct Model {
        let avatarURL: URL?
        let authorName: String
        let dateText: String
        let messageText: String
        let unreadCount: Int

        var hasUnreadMessages: Bool {
            unreadCount > 0
        }

        public init(
            avatarURL: URL?,
            authorName: String,
            dateText: String,
            messageText: String,
            unreadCount: Int
        ) {
            self.avatarURL = avatarURL
            self.authorName = authorName
            self.dateText = dateText
            self.messageText = messageText
            self.unreadCount = unreadCount
        }
    }
}

private extension DialogRowView {
    var leadingImage: some View {
        CachedImage(url: model.avatarURL, mode: .userListItem)
            .borderedClipshape()
    }

    var authorNameView: some View {
        Text(model.authorName)
            .foregroundColor(.swMainText)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var dateTextView: some View {
        Text(model.dateText)
            .foregroundColor(.swSmallElements)
            .font(.footnote.weight(.medium))
    }

    var messageView: some View {
        Text(model.messageText)
            .font(.subheadline)
            .foregroundColor(.swSmallElements)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
#Preview {
    DialogRowView(
        model: .init(
            avatarURL: .init(string: "https://workout.su/uploads/avatars/2019/10/2019-10-07-01-10-08-yow.jpg")!,
            authorName: "angryswan732",
            dateText: "12:30",
            messageText: "Привет)) Давай в 18:30?",
            unreadCount: 3
        )
    )
    .previewLayout(.sizeThatFits)
}
#endif
