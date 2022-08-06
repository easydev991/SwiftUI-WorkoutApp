import Foundation

@MainActor
final class DialogListViewModel: ObservableObject {
    @Published var list = [DialogResponse]()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    func makeItems(with defaults: DefaultsService, refresh: Bool) async {
        if isLoading || (!list.isEmpty && !refresh) { return }
        if !refresh { isLoading.toggle() }
        do {
            list = try await APIService(with: defaults).getDialogs()
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        if !refresh { isLoading.toggle() }
    }

    func deleteDialog(at index: Int?, with defaults: DefaultsService) async {
        guard let index = index, !isLoading else { return }
        isLoading.toggle()
        do {
            let dialogID = list[index].id
            if try await APIService(with: defaults).deleteDialog(dialogID) {
                list.remove(at: index)
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}
