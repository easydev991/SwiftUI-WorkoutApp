import SwiftUI

public struct SWTextField: View {
    private let placeholder: String
    @Binding private var text: String
    private let isSecure: Bool
    private let isFocused: Bool
    private let errorState: ErrorState?

    /// Инициализирует `SWTextField`
    /// - Parameters:
    ///   - placeholder: Плейсхолдер
    ///   - text: Текст
    ///   - isSecure: `true` - нужно прятать текст, `false` - не нужно, по умолчанию `false`
    ///   - isFocused: `true` - текстфилд сфокусирован, `false` - нет. Влияет на цвет рамки
    ///   - errorState: Состояние ошибки, по умолчанию отсутствует
    public init(
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool = false,
        isFocused: Bool,
        errorState: ErrorState? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.isFocused = isFocused
        self.errorState = errorState
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
        .animation(.default, value: errorState)
    }
}

public extension SWTextField {
    enum ErrorState: Equatable {
        case noMessage
        case message(String)

        var message: String? {
            if case let .message(text) = self, !text.isEmpty {
                return text
            } else {
                return nil
            }
        }
    }
}

private extension SWTextField {
    @ViewBuilder
    var textFieldView: some View {
        if #available(iOS 16.0, *) {
            textField.tint(.swAccent)
        } else {
            textField.accentColor(.swAccent)
        }
    }

    @ViewBuilder
    var textField: some View {
        if isSecure {
            SecureField(placeholder, text: $text)
        } else {
            TextField(placeholder, text: $text)
        }
    }

    @ViewBuilder
    var errorMessageViewIfNeeded: some View {
        if let message = errorState?.message {
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .foregroundColor(.swError)
        }
    }

    var borderColor: Color {
        guard errorState == nil else {
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
                text: .constant(""),
                isFocused: false
            )
            SWTextField(
                placeholder: "Placeholder",
                text: .constant(""),
                isSecure: true,
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
                errorState: .noMessage
            )
            SWTextField(
                placeholder: "Placeholder",
                text: .constant("Text"),
                isFocused: false,
                errorState: .message("Error message")
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
