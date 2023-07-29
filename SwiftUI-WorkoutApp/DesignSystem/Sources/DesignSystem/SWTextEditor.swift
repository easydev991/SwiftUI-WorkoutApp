import SwiftUI

public struct SWTextEditor: View {
    @Binding private var text: String
    private let placeholder: String?
    private let isFocused: Bool
    private let height: CGFloat
    
    /// Инициализирует `SWTextEditor`
    /// - Parameters:
    ///   - text: Текст
    ///   - placeholder: Плейсхолдер
    ///   - isFocused: Состояние фокусировки
    ///   - height: Высота вьюшки для ввода текста
    public init(
        text: Binding<String>,
        placeholder: String? = nil,
        isFocused: Bool,
        height: CGFloat
    ) {
        self._text = text
        self.placeholder = placeholder
        self.isFocused = isFocused
        self.height = height
    }
    
    public var body: some View {
        TextEditor(text: $text)
            .accentColor(.swAccent)
            .frame(height: height)
            .padding(.horizontal, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isFocused ? Color.swAccent : Color.swSeparators,
                        lineWidth: 0.5
                    )
            )
            .animation(.default, value: isFocused)
            .overlay(alignment: .topLeading) {
                Text(placeholder ?? "")
                    .foregroundColor(.swSeparators)
                    .multilineTextAlignment(.leading)
                    .opacity(text.isEmpty ? 1 : 0)
                    .padding(.top, 10)
                    .padding(.horizontal, 12)
                    .allowsHitTesting(false)
            }
    }
}

#if DEBUG
struct SWTextEditor_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SWTextEditor(
                text: .constant(""),
                placeholder: "Добавьте немного подробностей о предстоящем мероприятии",
                isFocused: false,
                height: 100
            )
            SWTextEditor(
                text: .constant(""),
                placeholder: "Добавьте немного подробностей о предстоящем мероприятии",
                isFocused: true,
                height: 100
            )
            SWTextEditor(
                text: .constant("Мероприятие будет длится около трех часов, так что можно приходить в любое удобное время. Остались вопросы - задавайте в сообщениях."),
                placeholder: "Добавьте немного подробностей о предстоящем мероприятии",
                isFocused: true,
                height: 100
            )
        }
        .padding()
    }
}
#endif
