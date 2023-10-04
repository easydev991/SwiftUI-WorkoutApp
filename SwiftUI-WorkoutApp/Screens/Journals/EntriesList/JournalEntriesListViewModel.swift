import FeedbackSender
import Foundation
import SWModels
import SWNetworkClient

@MainActor
final class JournalEntriesListViewModel: ObservableObject {
    private let feedbackSender: FeedbackSender
    let userID: Int
    let currentJournal: JournalResponse
    @Published var newEntryText = ""
    @Published private(set) var list = [JournalEntryResponse]()
    @Published private(set) var isEntryCreated = false
    @Published private(set) var isSettingsUpdated = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    var canSaveNewEntry: Bool { !isLoading && !newEntryText.isEmpty }

    init(for userID: Int, with journal: JournalResponse) {
        self.userID = userID
        self.currentJournal = journal
        self.feedbackSender = FeedbackSenderImp()
    }

    func makeItems(with defaults: DefaultsProtocol, refresh: Bool) async {
        if isLoading || !list.isEmpty, !refresh { return }
        if !refresh { isLoading.toggle() }
        do {
            list = try await SWClient(with: defaults).getJournalEntries(for: userID, journalID: currentJournal.id)
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        if !refresh { isLoading.toggle() }
    }

    /// Проверяем возможность удаления указанной записи
    ///
    /// Сервер не дает удалить самую первую запись в дневнике
    func checkIfCanDelete(entry: JournalEntryResponse) -> Bool {
        entry.id != list.map(\.id).min()
    }

    func delete(_ entryID: Int?, with defaults: DefaultsProtocol) async {
        guard let entryID, !isLoading else { return }
        isLoading.toggle()
        do {
            if try await SWClient(with: defaults).deleteEntry(
                from: .journal(ownerId: userID, journalId: currentJournal.id),
                entryID: entryID
            ) {
                list.removeAll(where: { $0.id == entryID })
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func reportEntry(_ entry: JournalEntryResponse) {
        let complaint = Complaint.journalEntry(
            author: entry.authorName ?? "неизвестен",
            entryText: entry.formattedMessage
        )
        feedbackSender.sendFeedback(
            subject: complaint.subject,
            messageBody: complaint.body,
            recipients: Constants.feedbackRecipient
        )
    }

    func clearErrorMessage() { errorMessage = "" }
}
