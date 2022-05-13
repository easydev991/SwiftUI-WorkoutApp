//
//  SportsGroundViewCell.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 13.05.2022.
//

import SwiftUI

struct SportsGroundViewCell: View {
    let model: SportsGround

    var body: some View {
        HStack(spacing: 16) {
            CacheImageView(
                url: model.previewImageURL,
                mode: .sportsGround
            )
            VStack(alignment: .leading, spacing: 4) {
                Text(model.shortTitle)
                    .fontWeight(.medium)
                Text(model.address.valueOrEmpty)
                    .font(.caption)
                Text(model.trainings.description)
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
}

struct SportsGroundsForUserView_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundViewCell(model: .mock)
    }
}
