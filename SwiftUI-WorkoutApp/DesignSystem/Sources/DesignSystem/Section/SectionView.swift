import SwiftUI

public struct SectionView<Content: View>: View {
    private let header: String?
    private let footer: String?
    private let mode: Mode
    private let content: Content
    
    public init(
        header: String?,
        footer: String? = nil,
        mode: Mode,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header
        self.footer = footer
        self.mode = mode
        self.content = content()
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if let header {
                SectionSupplementaryView(header, mode: .header)
            }
            contentView
            if let footer {
                SectionSupplementaryView(footer, mode: .footer)
            }
        }
        .padding(.horizontal)
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
}

#if DEBUG
struct SectionView_Previews: PreviewProvider {
    static let contentText = "Content Content Content Content Content Content Content Content Content Content Content Content Content"
    
    static var previews: some View {
        VStack(spacing: 20) {
            SectionView(
                header: "Header",
                footer: "Footer",
                mode: .regular
            ) {
                Text(contentText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            SectionView(
                header: "Header",
                footer: "Footer",
                mode: .card()
            ) {
                Text(contentText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
        }
    }
}
#endif
