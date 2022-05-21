//
//  DialogListView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 21.05.2022.
//

import SwiftUI

struct DialogListView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = DialogListViewModel()
    @State private var editMode = EditMode.inactive
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
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
                        DialogListCell(with: dialog)
                    }
                }
                .onDelete { indexSet in
                    deleteDialogTask = Task {
                        await viewModel.deleteDialog(at: indexSet.first, with: defaults)
                    }
                }
            }
            .disabled(viewModel.isLoading)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .task { await askForDialogs() }
        .refreshable { await askForDialogs(refresh: true) }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .environment(\.editMode, $editMode)
        .onDisappear(perform: cancelTask)
        .navigationBarTitleDisplayMode(titleMode)
    }
}

private extension DialogListView {
    var showEmptyView: Bool {
        !defaults.friendsIdsList.isEmpty
        && viewModel.list.isEmpty
    }

    var showDummyText: Bool {
        !showEmptyView && viewModel.list.isEmpty
    }

    var titleMode: NavigationBarItem.TitleDisplayMode {
        defaults.isAuthorized && !viewModel.list.isEmpty
        ? .inline
        : .large
    }

    func askForDialogs(refresh: Bool = false) async {
        await viewModel.makeItems(with: defaults, refresh: refresh)
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
