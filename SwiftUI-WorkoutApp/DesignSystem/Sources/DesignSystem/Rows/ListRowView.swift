import SwiftUI

/// В фигме называется "Элемент списка"
public struct ListRowView: View {
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
            trailingContent.view
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
        case iconWithText(Icons.ListRow, String)

        @ViewBuilder
        var view: some View {
            switch self {
            case let .text(text):
                makeTextView(with: text)
            case let .iconWithText(iconName, text):
                HStack(spacing: 12) {
                    ListRowView.LeadingContent.makeIconView(with: iconName)
                    makeTextView(with: text)
                }
            }
        }

        public static func makeIconView(with name: Icons.ListRow) -> some View {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .frame(width: 34, height: 34)
                .foregroundColor(.swTintedButton)
                .overlay {
                    Image(systemName: name.rawValue)
                        .foregroundColor(.swAccent)
                }
        }

        private func makeTextView(with text: String) -> some View {
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
        var view: some View {
            switch self {
            case .empty:
                EmptyView()
            case .chevron:
                Icons.Misc.chevronView
            case let .text(text):
                makeTextView(with: text)
            case let .textWithChevron(text):
                HStack(spacing: 12) {
                    makeTextView(with: text)
                    Icons.Misc.chevronView
                }
            }
        }

        private func makeTextView(with text: String) -> some View {
            Text(text).foregroundColor(.swSmallElements)
        }
    }
}

#if DEBUG
struct ListRowView_Previews: PreviewProvider {
    static let models: [(left: ListRowView.LeadingContent, right: ListRowView.TrailingContent)] = [
        (.text("Текст"), .empty),
        (.text("Текст"), .chevron),
        (.text("Текст"), .text("подпись")),
        (.text("Текст"), .textWithChevron("подпись")),
        (.iconWithText(.signPost, "Text"), .empty),
        (.iconWithText(.signPost, "Text"), .chevron),
        (.iconWithText(.signPost, "Text"), .text("подпись")),
        (.iconWithText(.signPost, "Text"), .textWithChevron("подпись"))
    ]
    static var previews: some View {
        VStack(spacing: 0) {
            ForEach(Array(zip(models.indices, models)), id: \.0) { _, model in
                ListRowView(leadingContent: model.left, trailingContent: model.right)
            }
        }
        .padding()
    }
}
#endif
