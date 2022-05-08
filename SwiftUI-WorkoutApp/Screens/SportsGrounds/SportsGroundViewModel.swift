//
//  SportsGroundViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import Foundation

final class SportsGroundViewModel: ObservableObject {
    let id: Int
    @Published var ground = SportsGround.emptyValue
    @Published private(set) var isPhotoGridShown = false
    @Published private(set) var photoColumns = Columns.one
    @Published var isMySportsGround = false
    @Published private(set) var showParticipants = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    var authorImageStringURL: String {
        ground.author.imageStringURL
    }

    init(groundID: Int) {
        id = groundID
    }

    func makeSportsGroundInfo(with defaults: UserDefaultsService) async {
        if isLoading || ground.id != .zero {
            return
        }
        errorMessage = ""
        await MainActor.run { isLoading.toggle() }
        do {
            if let model = try await APIService(with: defaults).getSportsGround(id: id) {
                await MainActor.run {
                    ground = model
                    isLoading.toggle()
                    updateState()
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading.toggle()
            }
        }
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
    }
}
