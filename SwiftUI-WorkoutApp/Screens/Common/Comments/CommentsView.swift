import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels

/// Список комментариев
struct CommentsView: View {
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    let items: [CommentResponse]
    let reportClbk: (CommentResponse) -> Void
    let deleteClbk: (Int) -> Void
    let editClbk: (CommentResponse) -> Void

    var body: some View {
        SectionView(headerWithPadding: "Комментарии", mode: .card()) {
            LazyVStack(spacing: 0) {
                ForEach(Array(zip(items.indices, items)), id: \.0) { index, comment in
                    CommentRowView(
                        avatarURL: comment.user?.avatarURL,
                        userName: (comment.user?.userName).valueOrEmpty,
                        dateText: comment.formattedDateString,
                        bodyText: comment.formattedBody,
                        isCommentByMainUser: comment.user?.userID == defaults.mainUserInfo?.userID,
                        isNetworkConnected: network.isConnected,
                        reportAction: { reportClbk(comment) },
                        editAction: { editClbk(comment) },
                        deleteAction: { deleteClbk(comment.id) }
                    )
                    .withDivider(if: index != items.endIndex - 1)
                }
            }
        }
    }
}

#if DEBUG
struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScrollView {
                CommentsView(
                    items: [.preview],
                    reportClbk: { _ in },
                    deleteClbk: { _ in },
                    editClbk: { _ in }
                )
            }
            .previewDisplayName("Light, single")
            ScrollView {
                CommentsView(
                    items: [.preview, .preview, .preview],
                    reportClbk: { _ in },
                    deleteClbk: { _ in },
                    editClbk: { _ in }
                )
            }
            .previewDisplayName("Light, multiple")
            Group {
                ScrollView {
                    CommentsView(
                        items: [.preview],
                        reportClbk: { _ in },
                        deleteClbk: { _ in },
                        editClbk: { _ in }
                    )
                    .environment(\.colorScheme, .dark)
                    .padding(.horizontal)
                }
                .previewDisplayName("Dark, single")
                ScrollView {
                    CommentsView(
                        items: [.preview, .preview, .preview],
                        reportClbk: { _ in },
                        deleteClbk: { _ in },
                        editClbk: { _ in }
                    )
                    .environment(\.colorScheme, .dark)
                }
                .previewDisplayName("Dark, multiple")
            }
            .background(.black)
        }
        .environmentObject(DefaultsService())
        .environmentObject(NetworkStatus())
    }
}
#endif
