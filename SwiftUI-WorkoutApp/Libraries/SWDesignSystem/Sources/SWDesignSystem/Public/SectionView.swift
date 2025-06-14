import SwiftUI

/// Аналог стандартного `Section`
public struct SectionView<Content: View>: View {
    private let header: HeaderFooter?
    private let footer: HeaderFooter?
    private let mode: Mode
    private let content: Content

    public init(
        mode: Mode,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            headerModel: nil,
            footerModel: nil,
            mode: mode,
            content: content
        )
    }

    public init(
        header: LocalizedStringKey? = nil,
        footer: LocalizedStringKey? = nil,
        mode: Mode,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            headerModel: .init(title: header, mode: .header(hasLeftPadding: false)),
            footerModel: .init(title: footer, mode: .footer),
            mode: mode,
            content: content
        )
    }

    public init(
        headerWithPadding: LocalizedStringKey? = nil,
        footer: LocalizedStringKey? = nil,
        mode: Mode,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            headerModel: .init(title: headerWithPadding, mode: .header(hasLeftPadding: true)),
            footerModel: .init(title: footer, mode: .footer),
            mode: mode,
            content: content
        )
    }

    public var body: some View {
        VStack(spacing: 0) {
            if let header {
                SectionSupplementaryView(header.title, mode: header.mode)
            }
            contentView
            if let footer {
                SectionSupplementaryView(footer.title, mode: footer.mode)
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch mode {
        case let .card(padding):
            content.insideCardBackground(padding: padding)
        case .regular:
            content
        }
    }
}

public extension SectionView {
    enum Mode {
        /// Добавляет контенту модификатор `insideCardBackground` с указанным паддингом
        case card(padding: CGFloat = 0)
        /// Не добавляет модификаторы контенту
        case regular
    }

    /// Модель для хедера/футера
    struct HeaderFooter {
        let title: LocalizedStringKey
        let mode: SectionSupplementaryView.Mode

        init?(title: LocalizedStringKey?, mode: SectionSupplementaryView.Mode) {
            guard let title else { return nil }
            self.title = title
            self.mode = mode
        }
    }

    private init(
        headerModel: HeaderFooter?,
        footerModel: HeaderFooter?,
        mode: Mode,
        @ViewBuilder content: () -> Content
    ) {
        self.header = headerModel
        self.footer = footerModel
        self.mode = mode
        self.content = content()
    }
}

#if DEBUG
#Preview {
    let contentText = "Content Content Content Content Content Content Content Content Content Content Content Content Content"
    return VStack(spacing: 20) {
        SectionView(header: "Header", footer: "Footer", mode: .regular) {
            Text(contentText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        SectionView(headerWithPadding: "Header", footer: "Footer", mode: .card()) {
            Text(contentText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }
    .padding(.horizontal)
}
#endif
