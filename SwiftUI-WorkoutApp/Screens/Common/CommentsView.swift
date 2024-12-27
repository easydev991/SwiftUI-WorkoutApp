import SWDesignSystem
import SwiftUI
import SWModels

/// Список комментариев
struct CommentsView: View {
    @Environment(\.networkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    let items: [CommentResponse]
    let reportClbk: (CommentResponse) -> Void
    let deleteClbk: (Int) -> Void
    let editClbk: (CommentResponse) -> Void
    let createCommentClbk: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            if !items.isEmpty {
                SectionView(headerWithPadding: "Комментарии", mode: .card()) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(zip(items.indices, items)), id: \.0) { index, comment in
                            CommentRowView(
                                avatarURL: comment.user?.avatarURL,
                                userName: comment.user?.userName ?? "",
                                dateText: comment.formattedDateString,
                                bodyText: comment.formattedBody,
                                isCommentByMainUser: comment.user?.id == defaults.mainUserInfo?.id,
                                isNetworkConnected: isNetworkConnected,
                                reportAction: { reportClbk(comment) },
                                editAction: { editClbk(comment) },
                                deleteAction: { deleteClbk(comment.id) }
                            )
                            .withDivider(if: index != items.endIndex - 1)
                        }
                    }
                }
            }
            if defaults.isAuthorized {
                Button("Добавить комментарий", action: createCommentClbk)
                    .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
            }
        }
    }
}

#if DEBUG
#Preview("Single") {
    CommentsView(
        items: [.preview],
        reportClbk: { _ in },
        deleteClbk: { _ in },
        editClbk: { _ in },
        createCommentClbk: {}
    )
    .padding(.horizontal)
    .environmentObject(DefaultsService())
}

#Preview("Multiple") {
    CommentsView(
        items: [.preview, .preview, .preview],
        reportClbk: { _ in },
        deleteClbk: { _ in },
        editClbk: { _ in },
        createCommentClbk: {}
    )
    .padding(.horizontal)
    .environmentObject(DefaultsService())
}
#endif
