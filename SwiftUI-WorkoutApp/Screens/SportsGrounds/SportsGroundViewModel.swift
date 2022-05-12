//
//  SportsGroundViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import Foundation

final class SportsGroundViewModel: ObservableObject {
    let groundID: Int
    @Published var ground = SportsGround.emptyValue
    @Published private(set) var isPhotoGridShown = false
    @Published private(set) var photoColumns = Columns.one
    @Published var isMySportsGround = false
    @Published private(set) var comments = [Comment]()
    @Published private(set) var showParticipants = false
    @Published private(set) var showComments = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    init(groundID: Int) { self.groundID = groundID }

    @MainActor
    func makeSportsGroundInfo(with defaults: UserDefaultsService, refresh: Bool = false) async {
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
            comments = model.comments ?? []
            updateState()
        } catch {
            errorMessage = error.localizedDescription
        }
        if !refresh { isLoading.toggle() }
    }

    @MainActor
    func delete(commentID: Int, with defaults: UserDefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            let isOk = try await APIService(with: defaults).deleteComment(from: groundID, commentID: commentID)
            if isOk {
                comments.removeAll(where: { $0.id == commentID} )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() {
        errorMessage = ""
    }
}

extension SportsGroundViewModel {
    enum Columns: Int {
        case one = 1, two, three
        init(_ photosCount: Int) {
            switch photosCount {
            case 1: self = .one
            case 2: self = .two
            default: self = .three
            }
        }
    }
}

private extension SportsGroundViewModel {
    func updateState() {
        isPhotoGridShown = !ground.photos.isEmpty
        photoColumns = .init(ground.photos.count)
        isMySportsGround = ground.mine
        showParticipants = ground.peopleTrainHereCount > .zero
        showComments = !comments.isEmpty
    }
}
