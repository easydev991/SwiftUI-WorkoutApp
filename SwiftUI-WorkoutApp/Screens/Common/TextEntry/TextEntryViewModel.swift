import Foundation

@MainActor
final class TextEntryViewModel: ObservableObject {
    @Published private(set) var isSuccess = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    func addNewEntry(_ mode: TextEntryView.Mode, entryText: String, defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            switch mode {
            case let .newForGround(id):
                isSuccess = try await APIService(with: defaults).addNewEntry(
                    to: .ground(id: id), entryText: entryText
                )
            case let .newForEvent(id):
                isSuccess = try await APIService(with: defaults).addNewEntry(
                    to: .event(id: id), entryText: entryText
                )
            case let .newForJournal(id):
                isSuccess = try await APIService(with: defaults).addNewEntry(
                    to: .journal(id: id), entryText: entryText
                )
            default: break
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func editEntry(for mode: TextEntryView.Mode, entryText: String, with defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            switch mode {
            case let .editGround(info):
                isSuccess = try await APIService(with: defaults).editEntry(
                    for: .ground(id: info.parentObjectID),
                    entryID: info.entryID,
                    newEntryText: entryText
                )
            case let .editEvent(info):
                isSuccess = try await APIService(with: defaults).editEntry(
                    for: .event(id: info.parentObjectID),
                    entryID: info.entryID,
                    newEntryText: entryText
                )
            case let .editJournalEntry(info):
                isSuccess = try await APIService(with: defaults).editEntry(
                    for: .journal(id: info.parentObjectID),
                    entryID: info.entryID,
                    newEntryText: entryText
                )
            default: break
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func closedErrorAlert() { errorMessage = "" }
}
