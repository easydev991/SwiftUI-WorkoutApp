//
//  SportsGroundViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import SwiftUI

final class SportsGroundViewModel: ObservableObject {
    let ground: SportsGround
    @Published var isPhotoGridShown = false
    @Published var photoColumns = Columns.one
    @Published var isMySportsGround = false
    @Published var showParticipants = false

    init(with model: SportsGround) {
        self.ground = model
        isPhotoGridShown = !model.photos.isEmpty
        photoColumns = .init(model.photos.count)
        isMySportsGround = model.mine
        showParticipants = model.peopleTrainHereCount > .zero
    }

    enum Columns: Int {
        case one = 1, two, three
        var items: [GridItem] {
            .init(repeating: .init(.flexible()), count: rawValue)
        }
        init(_ photosCount: Int) {
            switch photosCount {
            case 1: self = .one
            case 2: self = .two
            default: self = .three
            }
        }
    }
}
