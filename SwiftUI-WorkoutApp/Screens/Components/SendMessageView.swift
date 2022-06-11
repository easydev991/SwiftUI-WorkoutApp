import SwiftUI

/// Универсальный экран для отправки текста на сервер
struct SendMessageView: View {
    @EnvironmentObject private var network: CheckNetworkService
    @Environment(\.dismiss) private var dismiss
    @Binding var text: String
    @Binding var showErrorAlert: Bool
    @Binding var errorTitle: String
    @FocusState private var isFocused
    private let header: String
    private let isLoading: Bool
    private let isSendButtonDisabled: Bool
    private let sendAction: () -> Void
    private let dismissError: () -> Void

    init(
        header: String,
        text: Binding<String>,
        isLoading: Bool,
        isSendButtonDisabled: Bool,
        sendAction: @escaping () -> Void,
        showErrorAlert: Binding<Bool>,
        errorTitle: Binding<String>,
        dismissError: @escaping () -> Void
    ) {
        self.header = header
        self._text = text
        self.isLoading = isLoading
        self.isSendButtonDisabled = isSendButtonDisabled
        self.sendAction = sendAction
        self._showErrorAlert = showErrorAlert
        self._errorTitle = errorTitle
        self.dismissError = dismissError
    }

    var body: some View {
        VStack {
            HeaderForSheet(title: header)
            Group {
                textView
                sendButtonStack
            }
            .padding(.horizontal)
            Spacer()
        }
        .overlay {
            ProgressView()
                .opacity(isLoading ? 1 : .zero)
        }
        .disabled(isLoading)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: dismissError) { TextOk() }
        }
    }
}

private extension SendMessageView {
    var sendButtonStack: some View {
        HStack {
            Spacer()
            sendButton
        }
    }

    var sendButton: some View {
        Button(action: sendAction) {
            Label("Отправить", systemImage: "paperplane.fill")
        }
        .tint(.blue)
        .buttonStyle(.borderedProminent)
        .disabled(isSendButtonDisabled || !network.isConnected)
    }

    var textView: some View {
        TextEditor(text: $text)
            .frame(height: 200)
            .padding(.horizontal, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray.opacity(0.5), lineWidth: 1)
            )
            .focused($isFocused)
            .onAppear(perform: showKeyboard)
    }

    func showKeyboard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isFocused.toggle()
        }
    }
}

struct SendMessageView_Previews: PreviewProvider {
    static var previews: some View {
        SendMessageView(
            header: "Новый комментарий",
            text: .constant(""),
            isLoading: false,
            isSendButtonDisabled: false,
            sendAction: {},
            showErrorAlert: .constant(false),
            errorTitle: .constant(""),
            dismissError: {}
        )
        .environmentObject(CheckNetworkService())
    }
}
