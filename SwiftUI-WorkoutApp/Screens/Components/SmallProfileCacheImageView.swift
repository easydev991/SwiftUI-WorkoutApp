//
//  SmallProfileCacheImageView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 11.05.2022.
//

import SwiftUI

struct SmallProfileCacheImageView: View {
    let url: URL?

    var body: some View {
        CacheAsyncImage(url: url) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .smallProfileImageRect()
            case .failure:
                Image(systemName: "person.fill")
            default:
                ProgressView()
            }
        }
    }
}

struct SmallProfileCacheImageView_Previews: PreviewProvider {
    static var previews: some View {
        SmallProfileCacheImageView(url: .init(string: "https://workout.su/img/avatar_default.jpg")!)
    }
}
