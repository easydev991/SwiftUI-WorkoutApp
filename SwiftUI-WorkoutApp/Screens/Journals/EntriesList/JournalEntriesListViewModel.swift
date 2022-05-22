//
//  JournalEntriesListViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 22.05.2022.
//

import Foundation

final class JournalEntriesListViewModel: ObservableObject {
    @Published var list = [JournalEntryResponse]()
    @Published var newEntryText = ""
    @Published private(set) var isEntryCreated = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    var canSaveNewEntry: Bool {
        !isLoading && !newEntryText.isEmpty
    }

    @MainActor
    func makeItems(for userID: Int, journalID: Int, with defaults: DefaultsService, refresh: Bool) async {
        if (isLoading || !list.isEmpty) && !refresh { return }
        if !refresh { isLoading.toggle() }
        do {
            list = try await APIService(with: defaults).getJournalEntries(for: userID, journalID: journalID)
        } catch {
            errorMessage = error.localizedDescription
        }
        if !refresh { isLoading.toggle() }
    }

    @MainActor
    func saveNewEntry(with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            let journalID = (list.first?.journalID).valueOrZero
            if try await APIService(with: defaults).saveJournalEntry(
                journalID: journalID,
                message: newEntryText
            ) {
                newEntryText = ""
                isEntryCreated.toggle()
                await makeItems(
                    for: defaults.mainUserID, journalID: journalID, with: defaults, refresh: true
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    @MainActor
    func deleteEntry(at index: Int?, with defaults: DefaultsService) async {
        guard let index = index, !isLoading else { return }
        isLoading.toggle()
        do {
            let journalID = list[index].journalID.valueOrZero
            let entryID = list[index].id
            if try await APIService(with: defaults).deleteJournalEntry(journalID: journalID, entryID: entryID) {
                list.remove(at: index)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}
