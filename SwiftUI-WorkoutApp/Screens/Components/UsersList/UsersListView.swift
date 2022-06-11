import SwiftUI

/// Экран со списком пользователей
struct UsersListView: View {
    @EnvironmentObject private var network: CheckNetworkService
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = UsersListViewModel()
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    let mode: Mode

    var body: some View {
        Form {
            if !viewModel.friendRequests.isEmpty {
                friendRequestsSection
            }
            List(viewModel.users, id: \.self) { model in
                NavigationLink {
                    UserDetailsView(from: model)
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    UserViewCell(model: model)
                }
                .disabled(model.id == defaults.mainUserID)
            }
        }
        .opacity(viewModel.isLoading ? 0.5 : 1)
        .overlay {
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .animation(.easeInOut, value: viewModel.isLoading)
        .disabled(viewModel.isLoading || !network.isConnected)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .task { await askForUsers() }
        .refreshable { await askForUsers(refresh: true) }
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension UsersListView {
    enum Mode {
        case friends(userID: Int)
        case participants(list: [UserResponse])
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
}

struct UsersListView_Previews: PreviewProvider {
    static var previews: some View {
        UsersListView(mode: .friends(userID: DefaultsService().mainUserID))
            .environmentObject(CheckNetworkService())
            .environmentObject(DefaultsService())
    }
}
