import SwiftUI

/// Список диалогов
struct DialogListView: View {
    @EnvironmentObject private var network: CheckNetworkService
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = DialogListViewModel()
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var indexToDelete: Int?
    @State private var openFriendList = false
    @State private var showDeleteConfirmation = false
    @State private var refreshTask: Task<Void, Never>?
    @State private var deleteDialogTask: Task<Void, Never>?

    var body: some View {
        Group {
            if viewModel.list.isEmpty {
                emptyContentView
            } else {
                dialogList
            }
        }
        .opacity(viewModel.isLoading ? 0.5 : 1)
        .overlay {
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .animation(.default, value: viewModel.isLoading)
        .confirmationDialog(
            Constants.Alert.deleteDialog,
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) { deleteDialogButton }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button("Ok", action: closeAlert)
        }
        .task { await askForDialogs() }
        .refreshable { await askForDialogs(refresh: true) }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                refreshButton
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                linkToFriends
            }
        }
        .onDisappear(perform: cancelTasks)
    }
}

private extension DialogListView {
    var refreshButton: some View {
        Button {
            refreshTask = Task {
                await askForDialogs()
            }
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
        }
        .opacity(showEmptyView ? 1 : .zero)
        .disabled(viewModel.isLoading)
    }

    var linkToFriends: some View {
        NavigationLink(isActive: $openFriendList) {
            if hasFriends {
                UsersListView(mode: .friends(userID: defaults.mainUserID))
                    .navigationTitle("Друзья")
            } else {
                SearchUsersView()
            }
        } label: {
            Image(systemName: "plus")
        }
        .opacity(hasFriends ? 1 : .zero)
        .disabled(!network.isConnected)
    }

    var emptyContentView: some View {
        EmptyContentView(
            message: "Чатов пока нет",
            buttonTitle: emptyViewButtonTitle,
            action: emptyViewAction
        )
        .opacity(showEmptyView ? 1 : .zero)
        .disabled(viewModel.isLoading)
    }

    var showEmptyView: Bool {
        viewModel.list.isEmpty
    }

    var emptyViewButtonTitle: String {
        hasFriends
        ? "Открыть список друзей"
        : "Найти пользователя"
    }

    var dialogList: some View {
        List {
            ForEach($viewModel.list) { $dialog in
                NavigationLink {
                    DialogView(dialog: $dialog)
                } label: {
                    GenericListCell(for: .dialog(dialog))
                }
            }
            .onDelete(perform: initiateDeletion)
        }
        .opacity(viewModel.isLoading ? 0.5 : 1)
        .animation(.default, value: viewModel.isLoading)
        .disabled(viewModel.isLoading)
    }

    var deleteDialogButton: some View {
        Button(role: .destructive) {
            deleteAction(at: indexToDelete)
        } label: {
            Text("Удалить")
        }
    }

    var hasFriends: Bool {
        defaults.hasFriends
    }

    func emptyViewAction() {
        openFriendList.toggle()
    }

    func askForDialogs(refresh: Bool = false) async {
        await viewModel.makeItems(with: defaults, refresh: refresh)
    }

    func initiateDeletion(at indexSet: IndexSet) {
        indexToDelete = indexSet.first
        showDeleteConfirmation.toggle()
    }

    func deleteAction(at index: Int?) {
        deleteDialogTask = Task {
            await viewModel.deleteDialog(at: index, with: defaults)
        }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func cancelTasks() {
        [refreshTask, deleteDialogTask].forEach { $0?.cancel() }
    }
}

struct DialogListView_Previews: PreviewProvider {
    static var previews: some View {
        DialogListView()
            .environmentObject(CheckNetworkService())
            .environmentObject(DefaultsService())
    }
}
