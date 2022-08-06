import Foundation

@MainActor
final class JournalSettingsViewModel: ObservableObject {
    @Published private(set) var isSettingsUpdated = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    func editJournalSettings(for journal: JournalResponse, with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).editJournalSettings(
                for: journal.id, title: journal.title, viewAccess: journal.viewAccessType, commentAccess: journal.commentAccessType) {
                isSettingsUpdated.toggle()
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}
