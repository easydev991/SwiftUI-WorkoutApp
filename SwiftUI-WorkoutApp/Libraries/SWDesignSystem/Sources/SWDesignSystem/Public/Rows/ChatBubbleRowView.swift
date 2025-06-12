import SwiftUI

public struct ChatBubbleRowView: View {
    private let messageType: MessageType
    private let message: String
    private let messageTime: String

    public init(
        messageType: MessageType,
        message: String,
        messageTime: String
    ) {
        self.messageType = messageType
        self.message = message
        self.messageTime = messageTime
    }

    public var body: some View {
        VStack(
            alignment: messageType == .incoming ? .leading : .trailing,
            spacing: 6
        ) {
            Text(message)
                .foregroundStyle(messageType.messageColor)
                .padding(.vertical, 12)
                .padding(.horizontal, 18)
                .background {
                    Rectangle()
                        .fill(messageType.bubbleColor)
                        .clipShape(RoundedCornerShape(radius: 20, corners: corners))
                }
            Text(messageTime)
                .font(.caption2)
                .foregroundStyle(Color.swSmallElements)
        }
        .textSelection(.enabled)
        .padding(messageType == .sent ? .leading : .trailing, 50)
        .frame(
            maxWidth: .infinity,
            alignment: messageType == .incoming ? .leading : .trailing
        )
    }

    private var corners: UIRectCorner {
        switch messageType {
        case .incoming:
            return [.bottomLeft, .topRight, .bottomRight]
        case .sent:
            return [.topLeft, .bottomLeft, .topRight]
        }
    }
}

public extension ChatBubbleRowView {
    enum MessageType {
        case incoming, sent

        var bubbleColor: Color {
            self == .incoming ? .swDisabledButton : .swAccent
        }

        var messageColor: Color {
            self == .incoming ? .swMainText : .swFilledButtonText
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        ChatBubbleRowView(
            messageType: .incoming,
            message: "orem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse ut semper quam. Phasellus non mauris sem. Donec sed fermentum eros. Donec pretium nec turpis a semper.",
            messageTime: "11:22"
        )
        ChatBubbleRowView(
            messageType: .sent,
            message: "Phasellus non mauris sem. Donec sed fermentum eros.",
            messageTime: "11:23"
        )
    }
    .padding(.horizontal)
}
#endif
