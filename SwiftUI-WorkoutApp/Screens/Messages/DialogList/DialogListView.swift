import SwiftUI

/// Список диалогов
struct DialogListView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = DialogListViewModel()
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var indexToDelete: Int?
    @State private var showDeleteConfirmation = false
    @State private var deleteDialogTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            EmptyContentView(mode: .messages)
                .opacity(showEmptyView ? 1 : .zero)
            Text("Тут будут чаты с другими пользователями")
                .multilineTextAlignment(.center)
                .padding()
                .opacity(showDummyText ? 1 : .zero)
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
            .disabled(viewModel.isLoading)
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
        NavigationLink {
            UsersListView(mode: .friends(userID: defaults.mainUserID))
                .navigationTitle("Друзья")
        } label: {
            Image(systemName: "plus")
        }
        .opacity(hasFriends ? 1 : .zero)
    }

    var showEmptyView: Bool {
        hasFriends && viewModel.list.isEmpty
    }

    var hasFriends: Bool {
        !defaults.friendsIdsList.isEmpty
    }

    var showDummyText: Bool {
        !showEmptyView && viewModel.list.isEmpty
    }

    func askForDialogs(refresh: Bool = false) async {
        await viewModel.makeItems(with: defaults, refresh: refresh)
    }

    func initiateDeletion(at indexSet: IndexSet) {
        indexToDelete = indexSet.first
        showDeleteConfirmation.toggle()
    }

    var deleteDialogButton: some View {
        Button(role: .destructive) {
            deleteAction(at: indexToDelete)
        } label: {
            Text("Удалить")
        }
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
