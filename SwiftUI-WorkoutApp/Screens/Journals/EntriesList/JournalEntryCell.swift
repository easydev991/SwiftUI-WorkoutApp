import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels

struct JournalEntryCell: View {
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    let model: JournalEntryResponse
    let reportClbk: (JournalEntryResponse) -> Void
    let canDelete: Bool
    let deleteClbk: (Int) -> Void
    let editClbk: (JournalEntryResponse) -> Void

    var body: some View {
        JournalRowView(
            model: .init(
                avatarURL: model.imageURL,
                title: model.authorName.valueOrEmpty,
                dateText: model.messageDateString,
                bodyText: model.formattedMessage,
                menuOptions: menuOptions
            )
        )
    }
}

private extension JournalEntryCell {
    typealias OptionButton = JournalRowView.Model.GenericButtonModel
    var menuOptions: [OptionButton] {
        guard network.isConnected else { return [] }
        let isEntryByMainUser = model.authorID == defaults.mainUserInfo?.userID
        if isEntryByMainUser {
            var array = [OptionButton]()
            array.append(OptionButton(.edit, action: { editClbk(model) }))
            if canDelete {
                array.append(OptionButton(.delete, action: { deleteClbk(model.id) }))
            }
            return array
        } else {
            return [OptionButton(.report, action: { reportClbk(model) })]
        }
    }
}

#if DEBUG
struct JournalEntryCell_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntryCell(
            model: .preview,
            reportClbk: { _ in },
            canDelete: true,
            deleteClbk: { _ in },
            editClbk: { _ in }
        )
        .environmentObject(NetworkStatus())
        .environmentObject(DefaultsService())
        .previewLayout(.sizeThatFits)
    }
}
#endif
