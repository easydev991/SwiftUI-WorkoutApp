import SwiftUI

#warning("Заменить на SWTextField")
/// Текстовое поле с картинкой слева для формы
struct TextFieldInForm: View {
    private let mode: Mode
    private let placeholder: String
    @Binding private var text: String

    init(
        mode: Mode,
        placeholder: String,
        text: Binding<String>
    ) {
        self.mode = mode
        self.placeholder = placeholder
        self._text = text
    }

    var body: some View {
        HStack {
            mode.systemImage
                .foregroundColor(.secondary)
            switch mode {
            case .regular:
                TextField(placeholder, text: $text)
            case .secure:
                SecureField(placeholder, text: $text)
            }
        }
    }
}

extension TextFieldInForm {
    enum Mode {
        case regular(systemImageName: String)
        case secure
    }
}

private extension TextFieldInForm.Mode {
    var systemImage: Image {
        switch self {
        case let .regular(imageName):
            return Image(systemName: imageName)
        case .secure:
            return Image(systemName: "lock")
        }
    }
}

#if DEBUG
struct TextFieldInForm_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            ForEach(TextFieldInForm.Mode.allCases, id: \.self) { mode in
                TextFieldInForm(
                    mode: mode,
                    placeholder: mode == .secure ? "Пароль" : "Логин или email",
                    text: .constant("")
                )
            }
        }
    }
}
#endif
