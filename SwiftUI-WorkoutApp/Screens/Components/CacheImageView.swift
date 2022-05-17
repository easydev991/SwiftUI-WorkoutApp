//
//  CacheImageView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 11.05.2022.
//

import SwiftUI

struct CacheImageView: View {
    let url: URL?
    var mode = Mode.user

    var body: some View {
        CacheAsyncImage(url: url, dummySize: mode.size) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .applySpecificSize(mode.size)
            default:
                Image("defaultWorkoutImage")
                    .resizable()
                    .applySpecificSize(mode.size)
            }
        }
    }
}

extension CacheImageView {
    enum Mode {
        case user, sportsGround
        var size: CGSize {
            self == .user
            ? .init(width: 36, height: 36)
            : .init(width: 60, height: 60)
        }
    }
}

struct SmallProfileCacheImageView_Previews: PreviewProvider {
    static var previews: some View {
        CacheImageView(url: .init(string: "https://workout.su/img/avatar_default.jpg")!)
    }
}
