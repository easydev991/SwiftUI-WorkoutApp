import Foundation
import SWModels
import SWNetworkClient

@MainActor
final class JournalsListViewModel: ObservableObject {
    @Published var list = [JournalResponse]()
    @Published var newJournalTitle = ""
    @Published private(set) var isJournalCreated = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    var canSaveNewJournal: Bool { !isLoading && !newJournalTitle.isEmpty }

    func makeItems(for userID: Int, refresh: Bool, with defaults: DefaultsProtocol) async {
        if isLoading || !list.isEmpty, !refresh { return }
        if !refresh { isLoading.toggle() }
        do {
            list = try await SWClient(with: defaults).getJournals(for: userID)
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        if !refresh { isLoading.toggle() }
    }

    func createJournal(with defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await SWClient(with: defaults).createJournal(with: newJournalTitle) {
                newJournalTitle = ""
                isJournalCreated.toggle()
                let userID = (defaults.mainUserInfo?.userID).valueOrZero
                await makeItems(for: userID, refresh: true, with: defaults)
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func update(journalID: Int, with defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            let userID = (defaults.mainUserInfo?.userID).valueOrZero
            let result = try await SWClient(with: defaults).getJournal(for: userID, journalID: journalID)
            if let index = list.firstIndex(where: { $0.id == journalID }) {
                list[index] = result
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func delete(journalID: Int?, with defaults: DefaultsProtocol) async {
        guard let journalID, !isLoading else { return }
        isLoading.toggle()
        do {
            if try await SWClient(with: defaults).deleteJournal(journalID: journalID) {
                list.removeAll(where: { $0.id == journalID })
                defaults.setUserNeedUpdate(true)
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}
