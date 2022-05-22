//
//  JournalsListViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 22.05.2022.
//

import Foundation

final class JournalsListViewModel: ObservableObject {
    @Published var list = [JournalResponse]()
    @Published var newJournalTitle = ""
    @Published private(set) var isJournalCreated = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    var canSaveNewJournal: Bool {
        !isLoading && !newJournalTitle.isEmpty
    }

    @MainActor
    func makeItems(for userID: Int, with defaults: DefaultsService, refresh: Bool) async {
        if (isLoading || !list.isEmpty) && !refresh { return }
        if !refresh { isLoading.toggle() }
        do {
            list = try await APIService(with: defaults).getJournals(for: userID)
        } catch {
            errorMessage = error.localizedDescription
        }
        if !refresh { isLoading.toggle() }
    }

    @MainActor
    func createJournal(with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).createJournal(with: newJournalTitle) {
                newJournalTitle = ""
                isJournalCreated.toggle()
                await makeItems(for: defaults.mainUserID, with: defaults, refresh: true)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    @MainActor
    func deleteJournal(at index: Int?, with defaults: DefaultsService) async {
        guard let index = index, !isLoading else { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).deleteJournal(journalID: list[index].id) {
                list.remove(at: index)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}
