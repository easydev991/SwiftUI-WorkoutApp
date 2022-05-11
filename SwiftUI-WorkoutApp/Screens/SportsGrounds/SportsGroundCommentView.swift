//
//  SportsGroundCommentView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 11.05.2022.
//

import SwiftUI

struct SportsGroundCommentView: View {
    let model: Comment

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 16) {
                SmallProfileCacheImageView(url: model.user?.avatarURL)
                nameDate
            }
            Text(model.body.valueOrEmpty.withoutHTML)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private extension SportsGroundCommentView {
    var nameDate: some View {
        VStack(alignment: .leading) {
            Text((model.user?.userName).valueOrEmpty)
                .fontWeight(.medium)
            Text(model.formattedDateString)
                .foregroundColor(.secondary)
                .font(.caption)
                .padding(.bottom, 4)
        }
    }
}

struct SportsGroundCommentView_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundCommentView(model: SportsGround.mock.comments!.first!)
            .padding()
    }
}
