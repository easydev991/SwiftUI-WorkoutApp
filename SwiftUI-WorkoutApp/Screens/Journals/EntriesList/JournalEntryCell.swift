import SwiftUI

struct JournalEntryCell: View {
    @EnvironmentObject private var network: CheckNetworkService
    @EnvironmentObject private var defaults: DefaultsService
    let model: JournalEntryResponse
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
                    Spacer()
                    Text(model.messageDateString)
                        .font(.callout)
                        .foregroundColor(.secondary)
                    if isMenuAvailable {
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
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .opacity(network.isConnected ? 1 : .zero)
        .onTapGesture { hapticFeedback(.rigid) }
    }

    var isMenuAvailable: Bool {
        model.authorID == defaults.mainUserID
    }
}

struct JournalEntryCell_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntryCell(
            model: .mock,
            deleteClbk: {_ in},
            editClbk: {_ in}
        )
        .environmentObject(CheckNetworkService())
        .environmentObject(DefaultsService())
        .previewLayout(.sizeThatFits)
    }
}
