//
//  JournalEntryCell.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 22.05.2022.
//

import SwiftUI

struct JournalEntryCell: View {
    let entry: JournalEntryResponse

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            CacheImageView(
                url: entry.imageURL,
                mode: .journalEntry
            )
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Text(entry.authorName.valueOrEmpty)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    Text(entry.messageDateString)
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                Text(entry.formattedMessage)
                    .font(.callout)
            }
        }
    }
}

struct JournalEntryCell_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntryCell(entry: .mock)
            .padding()
    }
}
