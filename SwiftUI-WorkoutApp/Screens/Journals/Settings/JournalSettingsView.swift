//
//  JournalSettingsView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 23.05.2022.
//

import SwiftUI

struct JournalSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @EnvironmentObject private var network: CheckNetworkService
    private let options = Constants.JournalAccess.allCases
    private let initialJournal: JournalResponse
    @StateObject private var viewModel = JournalSettingsViewModel()
    @State private var journal: JournalResponse
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @Binding private var updateOnSuccess: Bool
    @State private var saveJournalChangesTask: Task<Void, Never>?

    init(
        with journalToEdit: JournalResponse,
        needUpdate: Binding<Bool>
    ) {
        initialJournal = journalToEdit
        _journal = .init(initialValue: journalToEdit)
        _updateOnSuccess = needUpdate
    }

    var body: some View {
        ZStack {
            VStack(spacing: .zero) {
                headerView
                Form {
                    TextField("Название дневника", text: $journal.title)
                    visibilitySettings
                    commentsSettings
                    saveButton
                }
            }
            .disabled(viewModel.isLoading)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .interactiveDismissDisabled(viewModel.isLoading)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: viewModel.isSettingsUpdated, perform: finishSettings)
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .onDisappear(perform: cancelTask)
    }
}

private extension JournalSettingsView {
    var headerView: some View {
        HStack {
            Text("Настройки дневника")
                .font(.title3)
                .fontWeight(.medium)
            Spacer()
            Button(action: close) {
                DismissButton()
            }
            .disabled(viewModel.isLoading)
        }
        .padding()
    }

    var visibilitySettings: some View {
        Section("Кто видит записи") {
            Picker(
                "Доступ на просмотр",
                selection: $journal.viewAccessType
            ) {
                ForEach(options, id: \.self) {
                    Text($0.description)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    var commentsSettings: some View {
        Section("Кто может оставлять комментарии") {
            Picker(
                "Доступ на комментирование",
                selection: $journal.commentAccessType
            ) {
                ForEach(options, id: \.self) {
                    Text($0.description)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    var saveButton: some View {
        Button(action: saveChanges) {
            ButtonInFormLabel(title: "Сохранить")
        }
        .disabled(isSaveButtonDisabled)
    }

    func saveChanges() {
        saveJournalChangesTask = Task {
            await viewModel.editJournalSettings(for: journal, with: defaults)
        }
    }

    var isSaveButtonDisabled: Bool {
        viewModel.isLoading
        || !network.isConnected
        || journal.title.isEmpty
        || initialJournal == journal
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func close() { dismiss() }

    func finishSettings(isSuccess: Bool) {
        updateOnSuccess.toggle()
        close()
    }

    func cancelTask() {
        saveJournalChangesTask?.cancel()
    }
}

struct JournalSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        JournalSettingsView(with: .mock, needUpdate: .constant(false))
            .environmentObject(CheckNetworkService())
    }
}
