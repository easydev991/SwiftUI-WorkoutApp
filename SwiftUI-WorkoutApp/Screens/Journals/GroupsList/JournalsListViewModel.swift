//
//  JournalsListViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 22.05.2022.
//

import Foundation

final class JournalsListViewModel: ObservableObject {
    @Published var list = [JournalResponse]()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    @MainActor
    func makeItems(for userID: Int, with defaults: DefaultsService, refresh: Bool) async {
        if isLoading || (!list.isEmpty && !refresh) { return }
        if !refresh { isLoading.toggle() }
        do {
            list = try await APIService(with: defaults).getJournals(for: userID)
        } catch {
            errorMessage = error.localizedDescription
        }
        if !refresh { isLoading.toggle() }
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
