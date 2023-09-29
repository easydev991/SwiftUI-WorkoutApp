import DesignSystem
import SwiftUI
import SWModels

/// Экран для поиска других пользователей
struct SearchUsersView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var messagingViewModel = MessagingViewModel()
    @State private var users = [UserModel]()
    @State private var isLoading = false
    @State private var messageRecipient: UserModel?
    @State private var query = ""
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var searchTask: Task<Void, Never>?
    @State private var sendMessageTask: Task<Void, Never>?
    var mode = Mode.regular

    var body: some View {
        ScrollView {
            SectionView(header: "Результаты поиска", mode: .regular) {
                LazyVStack(spacing: 12) {
                    ForEach(users) { model in
                        listItem(for: model)
                            .disabled(model.id == defaults.mainUserInfo?.userID)
                            .accessibilityIdentifier("UserViewCell")
                    }
                }
            }
            .padding([.top, .horizontal])
        }
        .opacity(users.isEmpty ? 0 : 1)
        .searchable(
            text: $query,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Имя пользователя на английском")
        )
        .onSubmit(of: .search, search)
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .sheet(
            item: $messageRecipient,
            onDismiss: { endMessaging() },
            content: messageSheet
        )
        .alert(errorMessage, isPresented: $showErrorAlert) {
            Button("Ok", action: onCloseAlert)
        }
        .onChange(of: errorMessage, perform: setupErrorAlert)
        .onChange(of: messagingViewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: messagingViewModel.isMessageSent, perform: endMessaging)
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
                userRowView(with: model)
            }
        case .chat:
            Button {
                messageRecipient = model
            } label: {
                userRowView(with: model)
            }
        }
    }

    func userRowView(with model: UserModel) -> some View {
        UserRowView(
            mode: .regular(
                .init(
                    imageURL: model.imageURL,
                    name: model.name,
                    address: model.shortAddress
                )
            )
        )
    }

    func messageSheet(for recipient: UserModel) -> some View {
        SendMessageView(
            header: "Сообщение для \(recipient.name)",
            text: $messagingViewModel.messageText,
            isLoading: messagingViewModel.isLoading,
            isSendButtonDisabled: !messagingViewModel.canSendMessage,
            sendAction: { sendMessage(to: recipient.id) },
            showErrorAlert: $showErrorAlert,
            errorTitle: $errorMessage,
            dismissError: onCloseAlert
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
        if isLoading { return }
        isLoading.toggle()
        searchTask = Task {
            do {
                let result = try await APIService(with: defaults)
                    .findUsers(with: query.withoutSpaces)
                users = result.map(UserModel.init)
                if users.isEmpty {
                    errorMessage = "Не удалось найти такого пользователя"
                }
            } catch {
                errorMessage = ErrorFilterService.message(from: error)
            }
            isLoading.toggle()
        }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorMessage = message
    }

    func onCloseAlert() {
        errorMessage = ""
        messagingViewModel.clearErrorMessage()
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
