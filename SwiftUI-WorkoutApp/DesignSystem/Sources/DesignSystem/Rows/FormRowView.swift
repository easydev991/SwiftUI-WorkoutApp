import SwiftUI

/// В фигме называется "Ячейка формы"
public struct FormRowView: View {
    @Environment(\.isEnabled) private var isEnabled
    private let title: String
    private let trailingContent: TrailingContent

    /// Инициализирует `FormRowView`
    /// - Parameters:
    ///   - title: Заголовок (слева)
    ///   - trailingContent: Контент справа
    public init(
        title: String,
        trailingContent: TrailingContent
    ) {
        self.title = title
        self.trailingContent = trailingContent
    }

    public var body: some View {
        HStack(spacing: 12) {
            Text(.init(title))
                .font(.headline)
                .foregroundColor(.swMainText)
                .fixedSize()
                .frame(maxWidth: .infinity, alignment: .leading)
            trailingContent.makeView(isEnabled: isEnabled)
                .animation(.default, value: isEnabled)
        }
        .insideCardBackground()
    }
}

public extension FormRowView {
    enum TrailingContent {
        /// Тоггл
        case toggle(Binding<Bool>)
        /// Текст с шевроном
        case textWithChevron(String)
        /// Текст с бейджем и шевроном
        case textWithBadgeAndChevron(String, Int)

        @ViewBuilder
        func makeView(isEnabled: Bool) -> some View {
            switch self {
            case let .toggle($bool):
                Toggle("", isOn: $bool)
                    .tint(.swAccent)
            case let .textWithChevron(text):
                HStack(spacing: 12) {
                    trailingTextView(text)
                    if isEnabled { Icons.Misc.chevronView }
                }
            case let .textWithBadgeAndChevron(text, badgeValue):
                HStack(spacing: 12) {
                    trailingTextView(text)
                    if badgeValue > 0 {
                        BadgeView(value: badgeValue)
                    }
                    if isEnabled { Icons.Misc.chevronView }
                }
            }
        }

        private func trailingTextView(_ text: String) -> some View {
            Text(text)
                .font(.subheadline)
                .foregroundColor(.swSmallElements)
        }
    }
}

#if DEBUG
#Preview {
    Group {
        ForEach(ColorScheme.allCases, id: \.self) { scheme in
            VStack(spacing: 20) {
                FormRowView(title: "Друзья", trailingContent: .textWithChevron("56 друзей"))
                FormRowView(title: "Друзья", trailingContent: .textWithBadgeAndChevron("56 друзей", 5))
                FormRowView(title: "Где тренируется", trailingContent: .textWithChevron("26 площадок"))
                FormRowView(title: "Тренируюсь здесь", trailingContent: .toggle(.constant(true)))
            }
            .padding()
            .background(Color.swBackground)
            .environment(\.colorScheme, scheme)
            .previewDisplayName(scheme == .dark ? "Dark" : "Light")
        }
    }
    .previewLayout(.sizeThatFits)
}
#endif
