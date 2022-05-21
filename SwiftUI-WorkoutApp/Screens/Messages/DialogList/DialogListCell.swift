//
//  DialogListCell.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 21.05.2022.
//

import SwiftUI

struct DialogListCell: View {
    private let dialog: DialogResponse

    init(with dialog: DialogResponse) {
        self.dialog = dialog
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            CacheImageView(
                url: dialog.anotherUserImageURL,
                mode: .dialog
            )
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(dialog.anotherUserName.valueOrEmpty)
                        .font(.headline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    Spacer()
                    Text(dialog.lastMessageDateString)
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text(dialog.lastMessageFormatted)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    Spacer()
                    if dialog.unreadMessagesCount > .zero {
                        Image(systemName: "\(dialog.unreadMessagesCount).circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

struct DialogListCell_Previews: PreviewProvider {
    static var previews: some View {
        DialogListCell(with: .mock)
            .padding()
    }
}
