//
//  SportsGroundViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import Foundation

final class SportsGroundViewModel: ObservableObject {
    @Published var ground = SportsGround.emptyValue
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    var showRefreshButton: Bool {
        ground.id == .zero && !isLoading
    }

    @MainActor
    func makeSportsGroundInfo(groundID: Int, with defaults: DefaultsService, refresh: Bool = false) async {
        if (isLoading || ground.id != .zero) && !refresh {
            return
        }
        if !refresh { isLoading.toggle() }
        do {
            let model = try await APIService(with: defaults).getSportsGround(id: groundID)
            if model.id == .zero {
                errorMessage = Constants.Alert.cannotReadData
                if !refresh { isLoading.toggle() }
                return
            }
            ground = model
        } catch {
            errorMessage = error.localizedDescription
        }
        if !refresh { isLoading.toggle() }
    }

    @MainActor
    func delete(groundID: Int, commentID: Int, with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            let isOk = try await APIService(with: defaults).deleteComment(from: .ground(id: groundID), commentID: commentID)
            if isOk {
                ground.comments.removeAll(where: { $0.id == commentID} )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    @MainActor
    func changeTrainHereStatus(groundID: Int, trainHere: Bool, with defaults: DefaultsService) async {
        if isLoading || !defaults.isAuthorized { return }
        isLoading.toggle()
        do {
            let isOk = try await APIService(with: defaults).changeTrainHereStatus(for: groundID, trainHere: trainHere)
            if isOk {
                ground.trainHere = trainHere
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}
