//
//  JournalEntriesList.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 22.05.2022.
//

import SwiftUI

struct JournalEntriesList: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = JournalEntriesListViewModel()
    @State private var editMode = EditMode.inactive
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var showAccessSettings = false
    @State private var showEntrySheet = false
    @State private var editAccessTask: Task<Void, Never>?
    @State private var saveNewEntryTask: Task<Void, Never>?
    @State private var deleteEntryTask: Task<Void, Never>?
    let userID: Int
    let journal: JournalResponse

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.list) {
                    JournalEntryCell(entry: $0)
                }
                .onDelete { indexSet in
                    deleteEntryTask = Task {
                        await viewModel.deleteEntry(at: indexSet.first, with: defaults)
                    }
                }
            }
            .disabled(viewModel.isLoading)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .onChange(of: viewModel.isEntryCreated, perform: closeEntrySheet)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .task { await askForEntries() }
        .refreshable { await askForEntries(refresh: true) }
        .sheet(isPresented: $showEntrySheet) { newEntrySheet }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isMainUser {
                    settingsButton
                    addEntryButton
                }
            }
        }
        .onDisappear(perform: cancelTasks)
        .navigationTitle(journal.title.valueOrEmpty)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension JournalEntriesList {
    var settingsButton: some View {
        Button(action: showSettings) {
            Image(systemName: "gearshape.fill")
        }
    }

    func showSettings() {
        showAccessSettings.toggle()
    }

    var addEntryButton: some View {
        Button(action: showNewEntry) {
            Image(systemName: "plus")
        }
    }

    func showNewEntry() {
        showEntrySheet.toggle()
    }

    var newEntrySheet: some View {
        SendMessageView(
            text: $viewModel.newEntryText,
            isLoading: viewModel.isLoading,
            isSendButtonDisabled: !viewModel.canSaveNewEntry,
            sendAction: saveNewEntry,
            showErrorAlert: $showErrorAlert,
            errorTitle: $errorTitle,
            dismissError: closeAlert
        )
    }

    var isMainUser: Bool {
        userID == defaults.mainUserID
    }

    func askForEntries(refresh: Bool = false) async {
        await viewModel.makeItems(
            for: userID,
            journalID: journal.id,
            with: defaults,
            refresh: refresh
        )
    }

    func saveNewEntry() {
        saveNewEntryTask = Task {
            await viewModel.saveNewEntry(with: defaults)
        }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func closeEntrySheet(isSuccess: Bool) {
        showEntrySheet.toggle()
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func cancelTasks() {
        [editAccessTask, saveNewEntryTask, deleteEntryTask].forEach { $0?.cancel() }
    }
}

struct JournalEntriesList_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntriesList(userID: DefaultsService().mainUserID, journal: .mock)
            .environmentObject(DefaultsService())
    }
}
