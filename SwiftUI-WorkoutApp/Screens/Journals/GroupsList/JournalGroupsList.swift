//
//  JournalGroupsList.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 22.05.2022.
//

import SwiftUI

struct JournalGroupsList: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = JournalGroupsListViewModel()
    @State private var editMode = EditMode.inactive
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var deleteJournalGroupTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            EmptyContentView(mode: .journals)
                .opacity(showEmptyView ? 1 : .zero)
            List {
                ForEach($viewModel.list) { $journal in
                    NavigationLink {
                        Text("Записи в дневнике")
                    } label: {
                        GenericListCell(for: .journalGroup(journal))
                    }
                }
                .onDelete { indexSet in
                    deleteJournalGroupTask = Task {
                        await viewModel.deleteJournalGroup(at: indexSet.first, with: defaults)
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
        .task { await askForJournalGroups() }
        .refreshable { await askForJournalGroups(refresh: true) }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                addJournalButton
            }
        }
        .environment(\.editMode, $editMode)
        .onDisappear(perform: cancelDeleteTask)
    }
}

private extension JournalGroupsList {
    var showEmptyView: Bool {
        !defaults.hasJournals
        && viewModel.list.isEmpty
    }

    var addJournalButton: some View {
        NavigationLink(destination: Text("Создать дневник")) {
            Image(systemName: "plus")
        }
        .opacity(defaults.isAuthorized ? 1 : .zero)
    }

    func askForJournalGroups(refresh: Bool = false) async {
        await viewModel.makeItems(with: defaults, refresh: refresh)
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
        JournalGroupsList()
            .environmentObject(DefaultsService())
    }
}
