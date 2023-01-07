import SwiftUI

/// Кнопка с центрированным текстом для формы
struct ButtonInForm: View {
    private let title: String
    private let action: () -> Void
    private let mode: Mode

    init(_ title: String, mode: Mode = .primary, action: @escaping () -> Void) {
        self.title = title
        self.mode = mode
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(mode.font)
                .frame(maxWidth: .infinity)
        }
    }
}

extension ButtonInForm {
    enum Mode: CaseIterable {
        case primary, secondary
    }
}

private extension ButtonInForm.Mode {
    var font: Font { self == .primary ? .headline : .body }
}

#if DEBUG
struct ButtonInForm_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            ForEach(ButtonInForm.Mode.allCases, id: \.self) { mode in
                ButtonInForm("New Button", mode: mode, action: {})
            }
        }
    }
}
#endif
