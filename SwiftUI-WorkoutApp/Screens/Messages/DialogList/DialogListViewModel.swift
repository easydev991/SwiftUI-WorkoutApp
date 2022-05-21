//
//  DialogListViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 21.05.2022.
//

import Foundation

final class DialogListViewModel: ObservableObject {
    @Published var list = [DialogResponse]()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    @MainActor
    func makeItems(with defaults: DefaultsService, refresh: Bool) async {
        if isLoading || (!list.isEmpty && !refresh) { return }
        if !refresh { isLoading.toggle() }
        do {
            list = try await APIService(with: defaults).getDialogs()
        } catch {
            errorMessage = error.localizedDescription
        }
        if !refresh { isLoading.toggle() }
    }

    @MainActor
    func deleteDialog(at index: Int?, with defaults: DefaultsService) async {
        guard let index = index, !isLoading else { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).deleteDialog(list[index].id) {
                list.remove(at: index)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}
