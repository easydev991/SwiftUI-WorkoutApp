import SwiftUI

/// Выглядит аналогично стандартному заголовку/футеру секции в списке/форме
struct SectionSupplementaryView: View {
    private let text: String
    private let mode: Mode

    /// Инициализирует `SectionHeaderView`
    /// - Parameters:
    ///   - text: Текст
    ///   - mode: Режим (заголовок/футер)
    init(_ text: String, mode: Mode) {
        switch mode {
        case .header:
            self.text = text.uppercased()
        case .footer:
            self.text = text
        }
        self.mode = mode
    }

    var body: some View {
        Text(text)
            .foregroundColor(.swSmallElements)
            .font(.footnote)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, mode.hasLeftPadding ? 12 : 0)
            .padding(vPadding.edges, vPadding.value)
    }

    private var vPadding: (edges: Edge.Set, value: CGFloat) {
        switch mode {
        case .header: return (.bottom, 6)
        case .footer: return (.top, 12)
        }
    }
}

extension SectionSupplementaryView {
    enum Mode {
        case header(hasLeftPadding: Bool)
        case footer

        var hasLeftPadding: Bool {
            switch self {
            case let .header(hasLeftPadding):
                return hasLeftPadding
            case .footer:
                return true
            }
        }
    }
}

#if DEBUG
#Preview {
    let headers = ["Комментарии", "Друзья", "Результаты поиска"]
    return VStack(spacing: 0) {
        ForEach(headers, id: \.self) { text in
            SectionSupplementaryView(text, mode: .header(hasLeftPadding: true))
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.gray.opacity(0.3))
            SectionSupplementaryView(text, mode: .footer)
            SectionSupplementaryView(text, mode: .header(hasLeftPadding: false))
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.black.opacity(0.3))
            Spacer().frame(height: 50)
        }
    }
    .padding()
}
#endif
