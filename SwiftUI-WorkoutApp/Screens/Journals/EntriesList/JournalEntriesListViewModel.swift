import Foundation
import FeedbackSender

@MainActor
final class JournalEntriesListViewModel: ObservableObject {
    private let feedbackSender: FeedbackSender
    let userID: Int
    @Published var currentJournal: JournalResponse
    @Published var list = [JournalEntryResponse]()
    @Published var newEntryText = ""
    @Published private(set) var isEntryCreated = false
    @Published private(set) var isSettingsUpdated = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    var canSaveNewEntry: Bool {
        !isLoading && !newEntryText.isEmpty
    }

    init(for userID: Int, with journal: JournalResponse) {
        self.userID = userID
        currentJournal = journal
        feedbackSender = FeedbackSenderImp()
    }

    func makeItems(with defaults: DefaultsProtocol, refresh: Bool) async {
        if (isLoading || !list.isEmpty) && !refresh { return }
        if !refresh { isLoading.toggle() }
        do {
            list = try await APIService(with: defaults).getJournalEntries(for: userID, journalID: currentJournal.id)
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        if !refresh { isLoading.toggle() }
    }

    func delete(_ entryID: Int?, with defaults: DefaultsProtocol) async {
        guard let entryID = entryID, !isLoading else { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).deleteEntry(from: .journal(id: currentJournal.id), entryID: entryID) {
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
