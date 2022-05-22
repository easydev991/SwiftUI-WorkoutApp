//
//  GenericListCell.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 21.05.2022.
//

import SwiftUI

/// Ячейка для экранов "Дневники" и "Сообщения"
struct GenericListCell: View {
    private let content: Mode.Content

    init(for mode: Mode) {
        content = mode.content
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            CacheImageView(
                url: content.imageURL,
                mode: .generic
            )
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Text(content.title)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    Text(content.date)
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text(content.subtitle)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    Spacer()
                    if content.unreadCount > .zero {
                        Image(systemName: "\(content.unreadCount).circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

extension GenericListCell {
    enum Mode {
        case dialog(DialogResponse)
        case journalGroup(JournalResponse)
    }
}

private extension GenericListCell.Mode {
    var content: Content {
        switch self {
        case let .dialog(model):
            return .init(
                imageURL: model.anotherUserImageURL,
                title: model.anotherUserName.valueOrEmpty,
                subtitle: model.lastMessageFormatted,
                date: model.lastMessageDateString,
                unreadCount: model.unreadMessagesCount
            )
        case let .journalGroup(model):
            return .init(
                imageURL: model.imageURL,
                title: model.title.valueOrEmpty,
                subtitle: model.formattedLastMessage,
                date: model.lastMessageDateString
            )
        }
    }

    struct Content {
        let imageURL: URL?
        let title, subtitle, date: String
        var unreadCount = Int.zero
    }
}

struct DialogListCell_Previews: PreviewProvider {
    static var previews: some View {
        GenericListCell(for: .dialog(.mock))
            .padding()
    }
}
