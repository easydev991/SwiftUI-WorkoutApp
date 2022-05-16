//
//  EventViewCell.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.05.2022.
//

import SwiftUI

struct EventViewCell: View {
    let event: EventResponse

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            CacheImageView(
                url: event.previewImageURL,
                mode: .sportsGround
            )
            VStack(alignment: .leading, spacing: 4) {
                Text(event.formattedTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(event.shortAddress)
                    .font(.caption)
                Text(event.eventDateString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            print("--- event:")
            dump(event)
        }
    }
}

struct EventViewCell_Previews: PreviewProvider {
    static var previews: some View {
        EventViewCell(event: .mock)
    }
}
