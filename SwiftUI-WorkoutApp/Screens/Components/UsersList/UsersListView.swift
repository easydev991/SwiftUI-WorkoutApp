import SwiftUI

/// Экран со списком пользователей
struct UsersListView: View {
    @EnvironmentObject private var network: CheckNetworkService
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = UsersListViewModel()
    @State private var messageRecipient: UserModel?
    @State private var messageText = ""
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var sendMessageTask: Task<Void, Never>?
    let mode: Mode

    var body: some View {
        Form {
            if !viewModel.friendRequests.isEmpty {
                friendRequestsSection
            }
            List(viewModel.users, id: \.self) { model in
                listItem(for: model)
                    .disabled(model.id == defaults.mainUserInfo?.userID)
            }
        }
        .sheet(
            item: $messageRecipient,
            onDismiss: { endMessaging() },
            content: messageSheet
        )
        .opacity(viewModel.isLoading ? 0.5 : 1)
        .overlay {
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : 0)
        }
        .animation(.easeInOut, value: viewModel.isLoading)
        .disabled(viewModel.isLoading || !network.isConnected)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button("Ok", action: closeAlert)
        }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: viewModel.isMessageSent, perform: endMessaging)
        .task { await askForUsers() }
        .refreshable { await askForUsers(refresh: true) }
        .onDisappear(perform: cancelTasks)
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension UsersListView {
    enum Mode {
        case friends(userID: Int)
        case friendsForChat(userID: Int)
        case eventParticipants(list: [UserResponse])
        case groundParticipants(list: [UserResponse])
    }
}

private extension UsersListView.Mode {
    var title: String {
        switch self {
        case .friends, .friendsForChat:
            return "Друзья"
        case .eventParticipants:
            return "Пойдут на мероприятие"
        case .groundParticipants:
            return "Здесь тренируются"
        }
    }
}

private extension UsersListView {
    var friendRequestsSection: some View {
        Section {
            NavigationLink {
                FriendRequestsView(viewModel: viewModel)
            } label: {
                HStack {
                    Label("Заявки", systemImage: "person.fill.badge.plus")
                    Spacer()
                    Text(viewModel.friendRequests.count.description)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    func listItem(for model: UserModel) -> some View {
        switch mode {
        case .friendsForChat:
            Button {
                messageRecipient = model
            } label: {
                UserViewCell(model: model)
            }
        case .friends, .eventParticipants, .groundParticipants:
            NavigationLink {
                UserDetailsView(from: model)
                    .navigationBarTitleDisplayMode(.inline)
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
            dismissError: closeAlert
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

    func askForUsers(refresh: Bool = false) async {
        await viewModel.makeInfo(for: mode, refresh: refresh, with: defaults)
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func cancelTask() {
        sendMessageTask?.cancel()
    }
}

struct UsersListView_Previews: PreviewProvider {
    static var previews: some View {
        UsersListView(mode: .friends(userID: .previewUserID))
            .environmentObject(CheckNetworkService())
            .environmentObject(DefaultsService())
    }
}
