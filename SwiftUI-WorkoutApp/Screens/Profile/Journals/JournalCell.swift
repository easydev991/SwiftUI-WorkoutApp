import SWDesignSystem
import SwiftUI
import SWModels

struct JournalCell: View {
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    let model: JournalCommonInfo
    let mode: Mode
    let mainUserID: Int?
    let isJournalOwner: Bool

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
        guard isNetworkConnected else { return [] }
        let isEntryByMainUser = model.authorID == mainUserID
        switch mode {
        case let .root(setupClbk, deleteClbk):
            return isEntryByMainUser
                ? [.init(.setup, action: setupClbk), .init(.delete, action: deleteClbk)]
                : []
        case let .entry(editClbk, reportClbk, canDelete, deleteClbk):
            if isEntryByMainUser {
                var array = [OptionButton(.edit, action: editClbk)]
                if canDelete {
                    array.append(.init(.delete, action: deleteClbk))
                }
                return array
            } else if isJournalOwner {
                var array = [OptionButton(.report, action: reportClbk)]
                if canDelete {
                    array.append(.init(.delete, action: deleteClbk))
                }
                return array
            } else {
                return [.init(.report, action: reportClbk)]
            }
        }
    }
}

#if DEBUG
#Preview {
    JournalCell(
        model: .init(journalEntryResponse: .preview),
        mode: .root(setupClbk: {}, deleteClbk: {}),
        mainUserID: nil,
        isJournalOwner: true
    )
}
#endif
