import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels

struct CommentViewCell: View {
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    let model: CommentResponse
    let reportClbk: (CommentResponse) -> Void
    let deleteClbk: (Int) -> Void
    let editClbk: (CommentResponse) -> Void

    var body: some View {
        CommentRowView(
            avatarURL: model.user?.avatarURL,
            userName: (model.user?.userName).valueOrEmpty,
            dateText: model.formattedDateString,
            bodyText: model.formattedBody,
            isCommentByMainUser: isCommentByMainUser,
            isNetworkConnected: network.isConnected,
            reportAction: { reportClbk(model) },
            editAction: { editClbk(model) },
            deleteAction: { deleteClbk(model.id) }
        )
    }
}

private extension CommentViewCell {
    var isCommentByMainUser: Bool {
        model.user?.userID == defaults.mainUserInfo?.userID
    }
}

#if DEBUG
struct SportsGroundCommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentViewCell(
            model: .init(
                id: .zero,
                body: "Test comment",
                date: "2013-01-16T03:35:54+04:00",
                user: .preview
            ),
            reportClbk: { _ in },
            deleteClbk: { _ in },
            editClbk: { _ in }
        )
        .environmentObject(NetworkStatus())
        .environmentObject(DefaultsService())
        .previewLayout(.sizeThatFits)
    }
}
#endif
