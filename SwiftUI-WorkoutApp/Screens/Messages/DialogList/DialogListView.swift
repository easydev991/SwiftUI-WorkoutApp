import SwiftUI

/// Список диалогов
struct DialogListView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = DialogListViewModel()
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var indexToDelete: Int?
    @State private var openFriendList = false
    @State private var showDeleteConfirmation = false
    @State private var deleteDialogTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            if viewModel.list.isEmpty {
                emptyContentView
            } else {
                dialogList
            }
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .confirmationDialog(
            Constants.Alert.deleteDialog,
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) { deleteDialogButton }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .task { await askForDialogs() }
        .refreshable { await askForDialogs(refresh: true) }
        .toolbar { linkToFriends }
        .onDisappear(perform: cancelTask)
    }
}

private extension DialogListView {
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
    }

    var emptyViewButtonTitle: String {
        hasFriends
        ? "Открыть список друзей"
        : "Найти пользователя"
    }

    var emptyContentView: some View {
        EmptyContentView(
            message: "Чатов пока нет",
            buttonTitle: emptyViewButtonTitle,
            action: emptyViewAction
        )
        .opacity(viewModel.isLoading ? .zero : 1)
        .animation(.default, value: viewModel.isLoading)
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

    func cancelTask() {
        deleteDialogTask?.cancel()
    }
}

struct DialogListView_Previews: PreviewProvider {
    static var previews: some View {
        DialogListView()
            .environmentObject(DefaultsService())
    }
}
