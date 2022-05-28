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
    func update(journalID: Int, with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            let result = try await APIService(with: defaults).getJournal(for: defaults.mainUserID, journalID: journalID)
            list.removeAll(where: { $0.id == journalID })
            list.append(result)
            list.sort(by: { $0.id > $1.id})
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    @MainActor
    func delete(journalID: Int?, with defaults: DefaultsService) async {
        guard let journalID = journalID, !isLoading else { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).deleteJournal(journalID: journalID) {
                list.removeAll(where: { $0.id == journalID })
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}
