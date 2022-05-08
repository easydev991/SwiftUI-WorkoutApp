//
//  FriendRequestRow.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 08.05.2022.
//

import SwiftUI

struct FriendRequestRow: View {
    let model: UserModel
    let acceptClbk: () -> Void
    let declineClbk: () -> Void

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 16) {
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
                    VStack(alignment: .leading) {
                        Text(model.name)
                        Text(model.shortAddress)
                    }
                }
                HStack(spacing: 16) {
                    Button(action: acceptClbk) {
                        Text("Принять")
                    }
                    .tint(.blue)
                    Button(role: .destructive, action: declineClbk) {
                        Text("Отклонить")
                    }
                    .tint(.red)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
            }
        }
    }
}

struct FriendRequestRow_Previews: PreviewProvider {
    static var previews: some View {
        FriendRequestRow(model: .emptyValue, acceptClbk: {}, declineClbk: {})
            .previewDevice("iPhone 13 mini")
    }
}
