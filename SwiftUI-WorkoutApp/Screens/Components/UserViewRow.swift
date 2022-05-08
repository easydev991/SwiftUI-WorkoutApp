//
//  UserViewRow.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 03.05.2022.
//

import SwiftUI

struct UserViewRow: View {
    let model: UserModel

    var body: some View {
        HStack(spacing: 16) {
            profileImage
            VStack(alignment: .leading) {
                Text(model.name)
                    .fontWeight(.medium)
                Text("model.shortAddress")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
}

private extension UserViewRow {
    var profileImage: some View {
        CacheAsyncImage(url: model.imageURL) { phase in
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

struct UserViewRow_Previews: PreviewProvider {
    static var previews: some View {
        UserViewRow(model: .emptyValue)
    }
}
