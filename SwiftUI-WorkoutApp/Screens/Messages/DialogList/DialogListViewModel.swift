import Foundation

final class DialogListViewModel: ObservableObject {
    @Published var list = [DialogResponse]()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    @MainActor
    func makeItems(refresh: Bool) async {
        if isLoading || (!list.isEmpty && !refresh) { return }
        if !refresh { isLoading.toggle() }
        do {
            list = try await APIService().getDialogs()
        } catch {
            errorMessage = error.localizedDescription
        }
        if !refresh { isLoading.toggle() }
    }

    @MainActor
    func deleteDialog(at index: Int?) async {
        guard let index = index, !isLoading else { return }
        isLoading.toggle()
        do {
            if try await APIService().deleteDialog(list[index].id) {
                list.remove(at: index)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}
