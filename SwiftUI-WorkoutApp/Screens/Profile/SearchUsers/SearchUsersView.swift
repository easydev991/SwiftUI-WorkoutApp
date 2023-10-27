import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран для поиска других пользователей
struct SearchUsersView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @State private var messagingModel = MessagingModel()
    @State private var users = [UserModel]()
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
    func listItem(for model: UserModel) -> some View {
        switch mode {
        case .regular:
            NavigationLink(destination: UserDetailsView(from: model)) {
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

    func userRowView(with model: UserModel) -> some View {
        UserRowView(
            mode: .regular(
                .init(
                    imageURL: model.imageURL,
                    name: model.name,
                    address: SWAddress(model.countryID, model.cityID).address
                )
            )
        )
    }

    func messageSheet(for recipient: UserModel) -> some View {
        SendMessageView(
            header: "Сообщение для \(recipient.name)",
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
                setupErrorAlert(with: ErrorFilter.message(from: error))
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
        if isLoading { return }
        isLoading.toggle()
        searchTask = Task {
            do {
                let result = try await SWClient(with: defaults)
                    .findUsers(with: query.withoutSpaces)
                users = result.map(UserModel.init)
                if users.isEmpty {
                    errorMessage = "Не удалось найти такого пользователя"
                }
            } catch {
                errorMessage = ErrorFilter.message(from: error)
            }
            isLoading.toggle()
        }
    }

    func setupErrorAlert(with message: String) {
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
