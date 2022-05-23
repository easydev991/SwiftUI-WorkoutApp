//
//  JournalSettingsView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 23.05.2022.
//

import SwiftUI

struct JournalSettingsView: View {
    private let options = Constants.JournalAccess.allCases
    @Binding var journal: JournalResponse
    let isLoading: Bool
    let isSaveButtonDisabled: Bool
    let saveAction: () -> Void
    @Binding var showErrorAlert: Bool
    @Binding var errorTitle: String
    let dismissError: () -> Void

    var body: some View {
        ZStack {
            Form {
                TextField("Название дневника", text: $journal.title)
                visibilitySettings
                commentsSettings
                saveButton
            }
            .disabled(isLoading)
            ProgressView()
                .opacity(isLoading ? 1 : .zero)
        }
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: dismissError) { TextOk() }
        }
    }
}

private extension JournalSettingsView {
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
        Button(action: saveAction) {
            ButtonInFormLabel(title: "Сохранить")
        }
        .disabled(isSaveButtonDisabled)
    }
}

struct JournalSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        JournalSettingsView(
            journal: .constant(.mock),
            isLoading: false,
            isSaveButtonDisabled: false,
            saveAction: {},
            showErrorAlert: .constant(false),
            errorTitle: .constant(""),
            dismissError: {}
        )
    }
}
