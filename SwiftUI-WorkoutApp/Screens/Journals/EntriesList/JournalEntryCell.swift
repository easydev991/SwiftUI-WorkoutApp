import SwiftUI

struct JournalEntryCell: View {
    @EnvironmentObject private var network: CheckNetworkService
    @EnvironmentObject private var defaults: DefaultsService
    let model: JournalEntryResponse
    let reportClbk: (JournalEntryResponse) -> Void
    let deleteClbk: (Int) -> Void
    let editClbk: (JournalEntryResponse) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            CacheImageView(
                url: model.imageURL,
                mode: .journalEntry
            )
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Text(model.authorName.valueOrEmpty)
                        .font(.headline)
                        .lineLimit(1)
                        .textSelection(.enabled)
                    Spacer()
                    Text(model.messageDateString)
                        .font(.callout)
                        .foregroundColor(.secondary)
                    if network.isConnected {
                        menuButton
                    }
                }
                Text(model.formattedMessage)
                    .font(.callout)
            }
        }
    }
}

private extension JournalEntryCell {
    var menuButton: some View {
        Menu {
            if isEntryByMainUser {
                Button {
                    editClbk(model)
                } label: {
                    Label("Изменить", systemImage: "rectangle.and.pencil.and.ellipsis")
                }
                Button(role: .destructive) {
                    deleteClbk(model.id)
                } label: {
                    Label("Удалить", systemImage: "trash")
                }
            } else {
                Button(role: .destructive) {
                    reportClbk(model)
                } label: {
                    Label("Пожаловаться", systemImage: "exclamationmark.triangle")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .opacity(network.isConnected ? 1 : 0)
        .onTapGesture { hapticFeedback(.rigid) }
    }

    var isEntryByMainUser: Bool {
        model.authorID == defaults.mainUserInfo?.userID
    }
}

#if DEBUG
struct JournalEntryCell_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntryCell(
            model: .preview,
            reportClbk: { _ in },
            deleteClbk: { _ in },
            editClbk: { _ in }
        )
        .environmentObject(CheckNetworkService())
        .environmentObject(DefaultsService())
        .previewLayout(.sizeThatFits)
    }
}
#endif
