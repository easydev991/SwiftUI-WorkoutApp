import SwiftUI

/// Выглядит аналогично стандартному заголовку/футеру секции в списке/форме
public struct SectionHeaderView: View {
    private let text: String
    private let mode: Mode
    
    /// Инициализирует `SectionHeaderView`
    /// - Parameters:
    ///   - text: Текст
    ///   - mode: Режим (заголовок/футер)
    public init(
        _ text: String,
        mode: Mode = .header
    ) {
        switch mode {
        case .header:
            self.text = text.uppercased()
        case .footer:
            self.text = text
        }
        self.mode = mode
    }

    public var body: some View {
        Text(text)
            .foregroundColor(.swSmallElements)
            .font(.footnote)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 12)
            .padding(vPadding.edges, vPadding.value)
    }
    
    private var vPadding: (edges: Edge.Set, value: CGFloat) {
        switch mode {
        case .header: return (.bottom, 6)
        case .footer: return (.top, 12)
        }
    }
}

public extension SectionHeaderView {
    enum Mode { case header, footer }
}

#if DEBUG
struct SectionHeaderView_Previews: PreviewProvider {
    static let headers = ["Комментарии", "Друзья", "Результаты поиска"]
    
    static var previews: some View {
        VStack(spacing: 0) {
            ForEach(headers, id: \.self) { text in
                SectionHeaderView(text, mode: .header)
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.gray.opacity(0.3))
                SectionHeaderView(text, mode: .footer)
                Spacer().frame(height: 50)
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
