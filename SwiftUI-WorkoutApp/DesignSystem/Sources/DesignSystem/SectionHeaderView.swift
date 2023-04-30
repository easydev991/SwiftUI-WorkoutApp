import SwiftUI

/// Выглядит аналогично стандартному заголовку/футеру секции в списке/форме
public struct SectionHeaderView: View {
    private let text: String
    private let verticalPadding: VerticalPadding
    
    /// Инициализирует `SectionHeaderView`
    /// - Parameters:
    ///   - text: Текст
    ///   - verticalPadding: Отступ сверху/снизу, по умолчанию отступ снизу
    public init(_ text: String, verticalPadding: VerticalPadding = .bottom) {
        self.text = text.uppercased()
        self.verticalPadding = verticalPadding
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
        switch verticalPadding {
        case .top: return (.top, 12)
        case .bottom: return (.bottom, 6)
        }
    }
}

public extension SectionHeaderView {
    enum VerticalPadding { case top, bottom }
}

#if DEBUG
struct SectionHeaderView_Previews: PreviewProvider {
    static let headers = ["Комментарии", "Друзья", "Результаты поиска"]
    
    static var previews: some View {
        VStack(spacing: 0) {
            ForEach(headers, id: \.self) { text in
                SectionHeaderView(text, verticalPadding: .bottom)
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.gray.opacity(0.3))
                SectionHeaderView(text, verticalPadding: .top)
                Spacer().frame(height: 50)
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
