//
//  JournalsList.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 22.05.2022.
//

import SwiftUI

struct JournalsList: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = JournalsListViewModel()
    @State private var editMode = EditMode.inactive
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var deleteJournalGroupTask: Task<Void, Never>?
    let userID: Int

    var body: some View {
        ZStack {
            EmptyContentView(mode: .journals)
                .opacity(showEmptyView ? 1 : .zero)
            List {
                ForEach(viewModel.list) { journal in
                    NavigationLink {
                        JournalEntriesList(userID: userID, journal: journal)
                    } label: {
                        GenericListCell(for: .journalGroup(journal))
                    }
                }
                .onDelete { indexSet in
                    deleteJournalGroupTask = Task {
                        await viewModel.deleteJournal(at: indexSet.first, with: defaults)
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
        .task { await askForJournals() }
        .refreshable { await askForJournals(refresh: true) }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if isMainUser {
                    EditButton()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if isMainUser {
                    addJournalButton
                }
            }
        }
        .environment(\.editMode, $editMode)
        .onDisappear(perform: cancelDeleteTask)
    }
}

private extension JournalsList {
    var showEmptyView: Bool {
        !defaults.hasJournals
        && viewModel.list.isEmpty
    }

    var isMainUser: Bool {
        userID == defaults.mainUserID
    }

    var addJournalButton: some View {
        NavigationLink(destination: Text("Создать дневник")) {
            Image(systemName: "plus")
        }
        .opacity(defaults.isAuthorized ? 1 : .zero)
    }

    func askForJournals(refresh: Bool = false) async {
        await viewModel.makeItems(for: userID, with: defaults, refresh: refresh)
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func cancelDeleteTask() {
        deleteJournalGroupTask?.cancel()
    }
}

struct JournalGroupsList_Previews: PreviewProvider {
    static var previews: some View {
        JournalsList(userID: DefaultsService().mainUserID)
            .environmentObject(DefaultsService())
    }
}
