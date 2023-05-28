import SwiftUI

public struct SWTextField: View {
    private let placeholder: String
    @Binding private var text: String
    private let isFocused: Bool
    private let errorMessage: String

    /// Инициализирует `SWTextField`
    /// - Parameters:
    ///   - placeholder: Плейсхолдер
    ///   - text: Текст
    ///   - isFocused: `true` - текстфилд сфокусирован, `false` - нет. Влияет на цвет рамки
    ///   - errorMessage: Сообщение об ошибке. По умолчанию пустое
    public init(
        placeholder: String,
        text: Binding<String>,
        isFocused: Bool,
        errorMessage: String = ""
    ) {
        self.placeholder = placeholder
        self._text = text
        self.isFocused = isFocused
        self.errorMessage = errorMessage
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            textFieldView
                .foregroundColor(.swMainText)
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: 0.5)
                        .animation(.default, value: isFocused)
                }
            errorMessageViewIfNeeded
        }
        .animation(.default, value: errorMessage)
    }
}

private extension SWTextField {
    @ViewBuilder
    var textFieldView: some View {
        if #available(iOS 16.0, *) {
            TextField(placeholder, text: $text)
                .tint(.swAccent)
        } else {
            TextField(placeholder, text: $text)
                .accentColor(.swAccent)
        }
    }

    @ViewBuilder
    var errorMessageViewIfNeeded: some View {
        if !errorMessage.isEmpty {
            Text(errorMessage)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .foregroundColor(.swError)
        }
    }

    var borderColor: Color {
        guard errorMessage.isEmpty else {
            return .swError
        }
        return isFocused ? .swAccent : .swSeparators
    }
}

#if DEBUG
struct SWTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SWTextField(
                placeholder: "Placeholder",
                text: .constant("Text"),
                isFocused: false
            )
            SWTextField(
                placeholder: "Placeholder",
                text: .constant("Text"),
                isFocused: true
            )
            SWTextField(
                placeholder: "Placeholder",
                text: .constant("Text"),
                isFocused: false,
                errorMessage: "Error message"
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
