import SWDesignSystem
import SwiftUI

/// Универсальный экран для отправки текста на сервер
struct SendMessageScreen: View {
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @Environment(\.dismiss) private var dismiss
    @Binding var text: String
    @Binding var errorTitle: String
    @FocusState private var isFocused
    private let header: LocalizedStringKey
    private let placeholder: String?
    private let isLoading: Bool
    private let isSendButtonDisabled: Bool
    private let sendAction: () -> Void
    private let dismissError: () -> Void

    init(
        header: LocalizedStringKey,
        placeholder: String? = nil,
        text: Binding<String>,
        isLoading: Bool,
        isSendButtonDisabled: Bool,
        sendAction: @escaping () -> Void,
        errorTitle: Binding<String>,
        dismissError: @escaping () -> Void
    ) {
        self.header = header
        self.placeholder = placeholder
        self._text = text
        self.isLoading = isLoading
        self.isSendButtonDisabled = isSendButtonDisabled
        self.sendAction = sendAction
        self._errorTitle = errorTitle
        self.dismissError = dismissError
    }

    var body: some View {
        ContentInSheet(title: header) {
            VStack {
                textView
                Spacer()
                sendButton
            }
            .padding([.horizontal, .bottom])
        }
        .background(Color.swBackground)
        .loadingOverlay(if: isLoading)
        .interactiveDismissDisabled(isLoading)
        .alert(
            errorTitle,
            isPresented: .init(
                get: { !errorTitle.isEmpty },
                set: { newValue in
                    if !newValue { errorTitle = "" }
                }
            )
        ) {
            Button("Ok", action: dismissError)
        }
    }
}

private extension SendMessageScreen {
    var sendButton: some View {
        Button("Отправить") {
            isFocused = false
            sendAction()
        }
        .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
        .disabled(isSendButtonDisabled || !isNetworkConnected)
    }

    var textView: some View {
        SWTextEditor(
            text: $text,
            placeholder: placeholder,
            isFocused: isFocused,
            height: 200
        )
        .focused($isFocused)
        .onAppear(perform: showKeyboard)
    }

    func showKeyboard() {
        guard !isFocused else { return }
        Task { @MainActor in
            try await Task.sleep(nanoseconds: 750_000_000)
            isFocused = true
        }
    }
}

#if DEBUG
#Preview {
    SendMessageScreen(
        header: "Новый комментарий",
        text: .constant("Текст комментария"),
        isLoading: false,
        isSendButtonDisabled: true,
        sendAction: {},
        errorTitle: .constant(""),
        dismissError: {}
    )
}
#endif
