import SwiftUI

/// Многострочное поле для ввода текста
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
        textEditorView
            .frame(height: height)
            .padding(.horizontal, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isFocused ? Color.swAccent : Color.swSeparators,
                        lineWidth: 1
                    )
            )
            .animation(.default, value: isFocused)
            .overlay(alignment: .topLeading) {
                if let placeholder {
                    Text(.init(placeholder))
                        .foregroundStyle(Color.swSeparators)
                        .multilineTextAlignment(.leading)
                        .opacity(text.isEmpty ? 1 : 0)
                        .padding(.top, 10)
                        .padding(.horizontal, 12)
                        .allowsHitTesting(false)
                }
            }
    }
}

private extension SWTextEditor {
    @ViewBuilder
    var textEditorView: some View {
        if #available(iOS 16.0, *) {
            TextEditor(text: $text)
                .tint(.swAccent)
                .scrollContentBackground(.hidden)
        } else {
            TextEditor(text: $text)
                .tint(.swAccent)
        }
    }
}

#if DEBUG
#Preview {
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
            text: .constant(
                "Мероприятие будет длится около трех часов, так что можно приходить в любое удобное время. Остались вопросы - задавайте в сообщениях."
            ),
            placeholder: "Добавьте немного подробностей о предстоящем мероприятии",
            isFocused: true,
            height: 100
        )
    }
    .padding(.horizontal)
}
#endif
