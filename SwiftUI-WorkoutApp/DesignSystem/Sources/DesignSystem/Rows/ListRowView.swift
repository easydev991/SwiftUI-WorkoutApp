import SwiftUI

/// В фигме называется "Элемент списка"
public struct ListRowView: View {
    @Environment(\.isEnabled) private var isEnabled
    private let leadingContent: LeadingContent
    private let trailingContent: TrailingContent

    /// Инициализирует `ListRowView`
    /// - Parameters:
    ///   - leadingContent: Контент слева
    ///   - trailingContent: Контент справа
    public init(
        leadingContent: LeadingContent,
        trailingContent: TrailingContent = .empty
    ) {
        self.leadingContent = leadingContent
        self.trailingContent = trailingContent
    }

    public var body: some View {
        HStack(spacing: 16) {
            leadingContent.view
                .frame(maxWidth: .infinity, alignment: .leading)
            trailingContent.makeView(isEnabled: isEnabled)
                .animation(.default, value: isEnabled)
        }
        .padding(.vertical, 10)
    }
}

public extension ListRowView {
    /// Контент слева
    enum LeadingContent {
        /// Текст
        case text(String)
        /// Иконка с текстом
        case iconWithText(Icons.Regular, String)

        @ViewBuilder
        var view: some View {
            switch self {
            case let .text(text):
                makeTextView(with: .init(text))
            case let .iconWithText(iconName, text):
                HStack(spacing: 12) {
                    ListRowView.LeadingContent.makeIconView(with: iconName)
                    makeTextView(with: .init(text))
                }
            }
        }

        public static func makeIconView(with name: Icons.Regular) -> some View {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .frame(width: 34, height: 34)
                .foregroundColor(.swTintedButton)
                .overlay {
                    Image(systemName: name.rawValue)
                        .foregroundColor(.swAccent)
                }
        }

        private func makeTextView(with text: LocalizedStringKey) -> some View {
            Text(text).foregroundColor(.swMainText)
        }
    }

    /// Контент справа
    enum TrailingContent {
        /// Пусто
        case empty
        /// Шеврон
        case chevron
        /// Текст
        case text(String)
        /// Текст с шевроном
        case textWithChevron(String)

        @ViewBuilder
        func makeView(isEnabled: Bool) -> some View {
            switch self {
            case .empty:
                EmptyView()
            case .chevron:
                if isEnabled { Icons.Misc.chevronView }
            case let .text(text):
                makeTextView(with: .init(text))
            case let .textWithChevron(text):
                HStack(spacing: 12) {
                    makeTextView(with: .init(text))
                    if isEnabled { Icons.Misc.chevronView }
                }
            }
        }

        private func makeTextView(with text: LocalizedStringKey) -> some View {
            Text(text).foregroundColor(.swSmallElements)
        }
    }
}

#if DEBUG
#Preview {
    let models: [(left: ListRowView.LeadingContent, right: ListRowView.TrailingContent)] = [
        (.text("Текст"), .empty),
        (.text("Текст"), .chevron),
        (.text("Текст"), .text("подпись")),
        (.text("Текст"), .textWithChevron("подпись")),
        (.iconWithText(.signPost, "Text"), .empty),
        (.iconWithText(.signPost, "Text"), .chevron),
        (.iconWithText(.signPost, "Text"), .text("подпись")),
        (.iconWithText(.signPost, "Text"), .textWithChevron("подпись"))
    ]
    return VStack(spacing: 0) {
        ForEach(Array(zip(models.indices, models)), id: \.0) { _, model in
            ListRowView(leadingContent: model.left, trailingContent: model.right)
        }
    }
    .padding()
}
#endif
