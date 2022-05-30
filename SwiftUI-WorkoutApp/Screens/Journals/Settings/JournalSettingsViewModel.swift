import Foundation

final class JournalSettingsViewModel: ObservableObject {
    @Published private(set) var isSettingsUpdated = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    @MainActor
    func editJournalSettings(for journal: JournalResponse) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService().editJournalSettings(
                for: journal.id, title: journal.title, viewAccess: journal.viewAccessType, commentAccess: journal.commentAccessType) {
                isSettingsUpdated.toggle()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}
