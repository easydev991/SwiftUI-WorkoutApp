import SwiftUI

struct ChatBubble<Content: View>: View {
    private let messageType: Constants.MessageType
    private let content: () -> Content

    init(
        _ messageType: Constants.MessageType,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.messageType = messageType
        self.content = content
    }

    var body: some View {
        HStack {
            if messageType == .sent {
                Spacer()
            }
            content().clipShape(ChatBubbleShape(messageType))
            if messageType == .incoming {
                Spacer()
            }
        }
        .padding([messageType == .incoming ? .leading : .trailing, .top, .bottom], 10)
        .padding(messageType == .sent ? .leading : .trailing, 50)
    }
}

struct ChatBubbleShape: Shape {
    private let position: Constants.MessageType
    init(_ position: Constants.MessageType) {
        self.position = position
    }

    func path(in rect: CGRect) -> Path {
        position == .incoming
        ? getLeftBubblePath(in: rect)
        : getRightBubblePath(in: rect)
    }

    private func getLeftBubblePath(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let path = Path { p in
            p.move(to: .init(x: 25, y: height))
            p.addLine(to: .init(x: width - 20, y: height))
            p.addCurve(
                to: .init(x: width, y: height - 20),
                control1: .init(x: width - 8, y: height),
                control2: .init(x: width, y: height - 8)
            )
            p.addLine(to: .init(x: width, y: 20))
            p.addCurve(
                to: .init(x: width - 20, y: .zero),
                control1: .init(x: width, y: 8),
                control2: .init(x: width - 8, y: .zero)
            )
            p.addLine(to: .init(x: 21, y: .zero))
            p.addCurve(
                to: .init(x: 4, y: 20),
                control1: .init(x: 12, y: .zero),
                control2: .init(x: 4, y: 8)
            )
            p.addLine(to: .init(x: 4, y: height - 11))
            p.addCurve(
                to: .init(x: .zero, y: height),
                control1: .init(x: 4, y: height - 1),
                control2: .init(x: .zero, y: height)
            )
            p.addLine(to: .init(x: -0.05, y: height - 0.01))
            p.addCurve(
                to: .init(x: 11.0, y: height - 4.0),
                control1: .init(x: 4.0, y: height + 0.5),
                control2: .init(x: 8, y: height - 1)
            )
            p.addCurve(
                to: .init(x: 25, y: height),
                control1: .init(x: 16, y: height),
                control2: .init(x: 20, y: height)
            )
        }
        return path
    }

    private func getRightBubblePath(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let path = Path { p in
            p.move(to: .init(x: 25, y: height))
            p.addLine(to: .init(x:  20, y: height))
            p.addCurve(
                to: .init(x: .zero, y: height - 20),
                control1: .init(x: 8, y: height),
                control2: .init(x: .zero, y: height - 8)
            )
            p.addLine(to: .init(x: .zero, y: 20))
            p.addCurve(
                to: .init(x: 20, y: .zero),
                control1: .init(x: .zero, y: 8),
                control2: .init(x: 8, y: .zero)
            )
            p.addLine(to: .init(x: width - 21, y: .zero))
            p.addCurve(
                to: .init(x: width - 4, y: 20),
                control1: .init(x: width - 12, y: .zero),
                control2: .init(x: width - 4, y: 8)
            )
            p.addLine(to: .init(x: width - 4, y: height - 11))
            p.addCurve(
                to: .init(x: width, y: height),
                control1: .init(x: width - 4, y: height - 1),
                control2: .init(x: width, y: height)
            )
            p.addLine(to: .init(x: width + 0.05, y: height - 0.01))
            p.addCurve(
                to: .init(x: width - 11, y: height - 4),
                control1: .init(x: width - 4, y: height + 0.5),
                control2: .init(x: width - 8, y: height - 1)
            )
            p.addCurve(
                to: .init(x: width - 25, y: height),
                control1: .init(x: width - 16, y: height),
                control2: .init(x: width - 20, y: height)
            )
        }
        return path
    }
}

struct ChatBubble_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ChatBubble(.incoming) {
                VStack(alignment: .trailing, spacing: 8) {
                    Text("orem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse ut semper quam. Phasellus non mauris sem. Donec sed fermentum eros. Donec pretium nec turpis a semper.")
                        .padding([.top, .leading, .trailing], 12)
                    Text("11:22")
                        .font(.caption2)
                        .padding(.trailing, 16)
                        .padding(.bottom, 4)
                        .opacity(0.75)
                }
                .foregroundColor(.white)
                .background(.blue)
            }
            ChatBubble(.sent) {
                VStack(alignment: .trailing, spacing: 8) {
                    Text("Lorem ipsumper.")
                        .padding([.top, .leading, .trailing], 12)
                    Text("11:22")
                        .font(.caption2)
                        .padding(.trailing, 16)
                        .padding(.bottom, 4)
                        .opacity(0.75)
                }
                .foregroundColor(.white)
                .background(.green)
            }
        }
        .textSelection(.enabled)
    }
}
