import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран для поиска других пользователей
struct SearchUsersView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @State private var messagingModel = MessagingModel()
    @State private var users = [UserResponse]()
    @State private var isLoading = false
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
                            .disabled(model.id == defaults.mainUserInfo?.id)
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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Закрыть") { dismiss() }
                    .accessibilityIdentifier("closeModalPageButton")
            }
        }
        .sheet(
            item: $messagingModel.recipient,
            onDismiss: { endMessaging() },
            content: messageSheet
        )
        .alert(errorMessage, isPresented: $showErrorAlert) {
            Button("Ok", action: onCloseAlert)
        }
        .onChange(of: errorMessage, perform: setupErrorAlert)
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
    func listItem(for model: UserResponse) -> some View {
        switch mode {
        case .regular:
            NavigationLink(destination: UserDetailsView(for: model)) {
                userRowView(with: model)
            }
        case .chat:
            Button {
                messagingModel.recipient = model
            } label: {
                userRowView(with: model)
            }
        }
    }

    func userRowView(with model: UserResponse) -> some View {
        UserRowView(
            mode: .regular(
                .init(
                    imageURL: model.avatarURL,
                    name: model.userName ?? "",
                    address: SWAddress(model.countryID, model.cityID)?.address ?? ""
                )
            )
        )
    }

    func messageSheet(for recipient: UserResponse) -> some View {
        SendMessageView(
            header: .init(recipient.messageFor),
            text: $messagingModel.message,
            isLoading: messagingModel.isLoading,
            isSendButtonDisabled: !messagingModel.canSendMessage,
            sendAction: { sendMessage(to: recipient.id) },
            showErrorAlert: $showErrorAlert,
            errorTitle: $errorMessage,
            dismissError: onCloseAlert
        )
    }

    func sendMessage(to userID: Int) {
        messagingModel.isLoading = true
        sendMessageTask = Task {
            do {
                let isSuccess = try await SWClient(with: defaults).sendMessage(messagingModel.message, to: userID)
                endMessaging(isSuccess: isSuccess)
            } catch {
                setupErrorAlert(ErrorFilter.message(from: error))
            }
            messagingModel.isLoading = false
        }
    }

    func endMessaging(isSuccess: Bool = true) {
        if isSuccess {
            messagingModel.message = ""
            messagingModel.recipient = nil
        }
    }

    func search() {
        isLoading = true
        searchTask = Task {
            do {
                let foundUsers = try await SWClient(with: defaults)
                    .findUsers(with: query.withoutSpaces)
                users = foundUsers
                if foundUsers.isEmpty {
                    errorMessage = "Не удалось найти такого пользователя"
                }
            } catch {
                errorMessage = ErrorFilter.message(from: error)
            }
            isLoading = false
        }
    }

    func setupErrorAlert(_ message: String) {
        showErrorAlert = !message.isEmpty
        errorMessage = message
    }

    func onCloseAlert() { errorMessage = "" }

    func cancelTasks() {
        [searchTask, sendMessageTask].forEach { $0?.cancel() }
    }
}

#if DEBUG
#Preview {
    SearchUsersView()
}
#endif
