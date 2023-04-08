import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels

struct JournalCell: View {
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    let model: JournalCommonInfo
    let mode: Mode

    var body: some View {
        JournalRowView(
            model: .init(
                avatarURL: model.imageURL,
                title: model.entryTitle,
                dateText: model.entryDateString,
                bodyText: model.formattedMessage,
                menuOptions: menuOptions
            )
        )
    }
}

extension JournalCell {
    enum Mode {
        case root(
            setupClbk: () -> Void,
            deleteClbk: () -> Void
        )
        case entry(
            editClbk: () -> Void,
            reportClbk: () -> Void,
            canDelete: Bool,
            deleteClbk: () -> Void
        )
    }
}

private extension JournalCell {
    typealias OptionButton = JournalRowView.Model.GenericButtonModel
    var menuOptions: [OptionButton] {
        guard network.isConnected else { return [] }
        let isEntryByMainUser = model.authorID == defaults.mainUserInfo?.userID
        switch mode {
        case let .root(setupClbk, deleteClbk):
            if isEntryByMainUser {
                var array = [OptionButton]()
                array.append(OptionButton(.setup, action: setupClbk))
                array.append(OptionButton(.delete, action: deleteClbk))
                return array
            } else {
                return []
            }
        case let .entry(editClbk, reportClbk, canDelete, deleteClbk):
            if isEntryByMainUser {
                var array = [OptionButton]()
                array.append(OptionButton(.edit, action: editClbk))
                if canDelete {
                    array.append(OptionButton(.delete, action: deleteClbk))
                }
                return array
            } else {
                return [OptionButton(.report, action: reportClbk)]
            }
        }
    }
}

#if DEBUG
struct JournalCell_Previews: PreviewProvider {
    static var previews: some View {
        JournalCell(
            model: .init(journalEntryResponse: .preview),
            mode: .root(setupClbk: {}, deleteClbk: {})
        )
        .environmentObject(NetworkStatus())
        .environmentObject(DefaultsService())
        .previewLayout(.sizeThatFits)
    }
}
#endif
