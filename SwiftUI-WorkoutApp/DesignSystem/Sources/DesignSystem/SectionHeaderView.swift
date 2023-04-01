import SwiftUI

/// Вьюшка с заголовком для секции
///
/// Выглядит аналогично стандартному заголовку секции в списке
public struct SectionHeaderView: View {
    private let headerText: String
    
    /// Инициализирует `SectionHeaderView`
    /// - Parameter headerText: Текст заголовка секции
    public init(_ headerText: String) {
        self.headerText = headerText.uppercased()
    }
    
    public var body: some View {
        Text(headerText)
            .foregroundColor(.swSmallElements)
            .font(.footnote)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 12)
    }
}

#if DEBUG
struct SectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeaderView("Комментарии")
            .previewLayout(.sizeThatFits)
    }
}
#endif
