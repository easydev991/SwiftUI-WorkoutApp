import SwiftUI

/// Экран для поиска других пользователей
struct SearchUsersView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = SearchUsersViewModel()
    @StateObject private var messagingViewModel = MessagingViewModel()
    @State private var messageRecipient: UserModel?
    @State private var query = ""
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var searchTask: Task<Void, Never>?
    @State private var sendMessageTask: Task<Void, Never>?
    @FocusState private var isFocused
    var mode = Mode.regular

    var body: some View {
        Form {
            Section {
                TextField("Имя пользователя на английском", text: $query)
                    .onSubmit(search)
                    .submitLabel(.search)
                    .focused($isFocused)
                    .accessibilityIdentifier("SearchUserNameField")
            }
            Section("Результаты поиска") {
                List(viewModel.users) { model in
                    listItem(for: model)
                        .disabled(model.id == defaults.mainUserInfo?.userID)
                        .accessibilityIdentifier("UserViewCell")
                }
            }
            .opacity(viewModel.users.isEmpty ? 0 : 1)
        }
        .sheet(
            item: $messageRecipient,
            onDismiss: { endMessaging() },
            content: messageSheet
        )
        .overlay {
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : 0)
        }
        .animation(.default, value: viewModel.isLoading)
        .disabled(viewModel.isLoading)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button("Ok", action: closeAlert)
        }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: messagingViewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: messagingViewModel.isMessageSent, perform: endMessaging)
        .onAppear(perform: showKeyboard)
        .onDisappear(perform: cancelTasks)
        .navigationTitle("Поиск пользователей")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension SearchUsersView {
    enum Mode {
        /// Обычный режим с возможностью перехода в профиль найденного пользователя
        case regular
        /// При нажатии на найденного пользователя открываем окно для отправки сообщения
        case chat
    }
}

private extension SearchUsersView {
    @ViewBuilder
    func listItem(for model: UserModel) -> some View {
        switch mode {
        case .regular:
            NavigationLink(destination: UserDetailsView(from: model)) {
                UserViewCell(model: model)
            }
        case .chat:
            Button {
                messageRecipient = model
            } label: {
                UserViewCell(model: model)
            }
        }
    }

    func messageSheet(for recipient: UserModel) -> some View {
        SendMessageView(
            header: "Сообщение для \(recipient.name)",
            text: $messagingViewModel.messageText,
            isLoading: messagingViewModel.isLoading,
            isSendButtonDisabled: !messagingViewModel.canSendMessage,
            sendAction: { sendMessage(to: recipient.id) },
            showErrorAlert: $showErrorAlert,
            errorTitle: $errorTitle,
            dismissError: closeAlert
        )
    }

    func sendMessage(to userID: Int) {
        sendMessageTask = Task {
            await messagingViewModel.sendMessage(to: userID, with: defaults)
        }
    }

    func endMessaging(isSuccess: Bool = true) {
        if isSuccess {
            messagingViewModel.messageText = ""
            messageRecipient = nil
        }
    }

    func search() {
        searchTask = Task { await viewModel.searchFor(user: query, with: defaults) }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
        messagingViewModel.clearErrorMessage()
    }

    func showKeyboard() {
        guard !isFocused else { return }
        Task { @MainActor in
            try await Task.sleep(nanoseconds: 750_000_000)
            isFocused = true
        }
    }

    func cancelTasks() {
        [searchTask, sendMessageTask].forEach { $0?.cancel() }
    }
}

#if DEBUG
struct SearchUsersView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUsersView()
    }
}
#endif
