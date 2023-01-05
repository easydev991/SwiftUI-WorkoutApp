import SwiftUI

/// Экран для поиска других пользователей
struct SearchUsersView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = SearchUsersViewModel()
    @State private var messageRecipient: UserModel?
    @State private var messageText = ""
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
                TextField("Найти пользователя", text: $query)
                    .onSubmit(search)
                    .submitLabel(.search)
                    .focused($isFocused)
            }
            Section("Результаты поиска") {
                List(viewModel.users) { model in
                    listItem(for: model)
                        .disabled(model.id == defaults.mainUserInfo?.userID)
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
            Button("Ok") { viewModel.clearErrorMessage() }
        }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: viewModel.isMessageSent, perform: endMessaging)
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
            NavigationLink {
                UserDetailsView(from: model)
            } label: {
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
            text: $messageText,
            isLoading: viewModel.isLoading,
            isSendButtonDisabled: messageText.isEmpty || viewModel.isLoading,
            sendAction: { sendMessage(to: recipient.id) },
            showErrorAlert: $showErrorAlert,
            errorTitle: $errorTitle,
            dismissError: { viewModel.clearErrorMessage() }
        )
    }

    func sendMessage(to userID: Int) {
        sendMessageTask = Task {
            await viewModel.send(messageText, to: userID, with: defaults)
        }
    }

    func endMessaging(isSuccess: Bool = true) {
        if isSuccess {
            messageText = ""
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

    func showKeyboard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isFocused.toggle()
        }
    }

    func cancelTasks() {
        [searchTask, sendMessageTask].forEach { $0?.cancel() }
    }
}

struct SearchUsersView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUsersView()
    }
}
