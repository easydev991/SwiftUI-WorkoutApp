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
    @Published var isPhotoGridShown = false
    @Published var photoColumns = Columns.one
    @Published var isMySportsGround = false
    @Published var showParticipants = false
    @Published var isLoading = false
    @Published var errorMessage = ""

    var authorImageStringURL: String {
        ground.author.imageStringURL
    }

    init(groundID: Int) {
        id = groundID
    }

    func makeSportsGroundInfo(with defaults: UserDefaultsService) async {
        if isLoading || ground.id != .zero { return }
        errorMessage = ""
        await MainActor.run { isLoading = true }
        do {
            if let model = try await APIService(with: defaults).getSportsGround(id: id) {
                await MainActor.run {
                    ground = model
                    isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
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
