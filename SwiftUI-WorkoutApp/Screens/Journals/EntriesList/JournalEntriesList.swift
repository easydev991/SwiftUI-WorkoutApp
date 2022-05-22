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
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var showAccessSettings = false
    @State private var editAccessTask: Task<Void, Never>?
    let userID: Int
    let journal: JournalResponse

    var body: some View {
        ZStack {
            List(viewModel.list) {
                JournalEntryCell(entry: $0)
            }
            .disabled(viewModel.isLoading)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .task { await askForEntries() }
        .refreshable { await askForEntries(refresh: true) }
        .toolbar { settingsButton }
        .onDisappear(perform: cancelEditTask)
        .navigationTitle(journal.title.valueOrEmpty)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension JournalEntriesList {
    var settingsButton: some View {
        Button(action: showSettings) {
            Image(systemName: "gearshape.fill")
        }
        .opacity(actionButtonOpacity)
    }

    var actionButtonOpacity: Double {
        userID == defaults.mainUserID ? 1 : .zero
    }

    func showSettings() {
        showAccessSettings.toggle()
    }

    func askForEntries(refresh: Bool = false) async {
        await viewModel.makeItems(
            for: userID,
            journalID: journal.id,
            with: defaults,
            refresh: refresh
        )
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func cancelEditTask() {
        editAccessTask?.cancel()
    }
}

struct JournalEntriesList_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntriesList(userID: DefaultsService().mainUserID, journal: .mock)
            .environmentObject(DefaultsService())
    }
}
