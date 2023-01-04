import SwiftUI

/// Ячейка для экранов с дневниками и диалогами
struct GenericListCell: View {
    @EnvironmentObject private var network: CheckNetworkService
    @EnvironmentObject private var defaults: DefaultsService
    private let mode: Mode

    init(for mode: Mode) {
        self.mode = mode
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            CacheImageView(
                url: mode.content.imageURL,
                mode: .genericListItem
            )
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Text(mode.content.title)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    Text(mode.content.date)
                        .font(.callout)
                        .foregroundColor(.secondary)
                    if isMenuAvailable {
                        menuButton
                    }
                }
                HStack {
                    Text(mode.content.subtitle)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    Spacer()
                    if mode.content.unreadCount > .zero {
                        Image(systemName: "\(mode.content.unreadCount).circle.fill")
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
        case journal(
            info: JournalResponse,
            editClbk: (JournalResponse) -> Void,
            deleteClbk: (Int) -> Void
        )
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
        case let .journal(model, _, _):
            return .init(
                imageURL: model.imageURL,
                title: model.title,
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

private extension GenericListCell {
    var menuButton: some View {
        Menu {
            Button {
                if case let .journal(info, edit, _) = mode {
                    edit(info)
                }
            } label: {
                Label("Настроить", systemImage: "gearshape.fill")
            }
            Button(role: .destructive) {
                if case let .journal(info, _, delete) = mode {
                    delete(info.id)
                }
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .onTapGesture { hapticFeedback(.rigid) }
    }

    var isMenuAvailable: Bool {
        switch mode {
        case .dialog:
            return false
        case let .journal(info, _, _):
            return (info.ownerID == defaults.mainUserID) && network.isConnected
        }
    }
}

struct GenericListCell_Previews: PreviewProvider {
    static var previews: some View {
        GenericListCell(for: .dialog(.preview))
            .environmentObject(CheckNetworkService())
            .previewLayout(.sizeThatFits)
    }
}
