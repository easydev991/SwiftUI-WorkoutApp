//
//  FriendRequestRow.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 08.05.2022.
//

import SwiftUI

struct FriendRequestRow: View {
    let model: UserModel
    let acceptClbk: (Int) -> Void
    let declineClbk: (Int) -> Void

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
                    Button(action: accept) {
                        Text("Принять")
                    }
                    .tint(.blue)
                    Button(role: .destructive, action: decline) {
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

private extension FriendRequestRow {
    func accept() { acceptClbk(model.id) }

    func decline() { declineClbk(model.id) }
}

struct FriendRequestRow_Previews: PreviewProvider {
    static var previews: some View {
        FriendRequestRow(model: .emptyValue, acceptClbk: {_ in}, declineClbk: {_ in})
            .previewDevice("iPhone 13 mini")
    }
}
