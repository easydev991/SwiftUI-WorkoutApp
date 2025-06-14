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
                .foregroundStyle(Color.swMainText)
                .fixedSize()
                .frame(maxWidth: .infinity, alignment: .leading)
            trailingContent.makeView(isEnabled: isEnabled)
                .animation(.default, value: isEnabled)
        }
        .insideCardBackground()
    }
}

public extension FormRowView {
    @MainActor
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
                    if isEnabled { ChevronView() }
                }
            case let .textWithBadgeAndChevron(text, badgeValue):
                HStack(spacing: 12) {
                    trailingTextView(text)
                    if badgeValue > 0 {
                        BadgeView(value: badgeValue)
                    }
                    if isEnabled { ChevronView() }
                }
            }
        }

        private func trailingTextView(_ text: String) -> some View {
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color.swSmallElements)
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 20) {
        FormRowView(title: "Друзья", trailingContent: .textWithChevron("56 друзей"))
        FormRowView(title: "Друзья", trailingContent: .textWithBadgeAndChevron("56 друзей", 5))
        FormRowView(title: "Где тренируется", trailingContent: .textWithChevron("26 площадок"))
        FormRowView(title: "Тренируюсь здесь", trailingContent: .toggle(.constant(true)))
    }
    .padding(.horizontal)
}
#endif
