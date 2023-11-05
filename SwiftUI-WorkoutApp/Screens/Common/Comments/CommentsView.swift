import NetworkStatus
import SWDesignSystem
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
    @Binding var isCreatingComment: Bool

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
            if defaults.isAuthorized {
                Button("Добавить комментарий") {
                    isCreatingComment.toggle()
                }
                .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
            }
        }
    }
}

#if DEBUG
#Preview {
    Group {
        ScrollView {
            CommentsView(
                items: [.preview],
                reportClbk: { _ in },
                deleteClbk: { _ in },
                editClbk: { _ in },
                isCreatingComment: .constant(false)
            )
        }
        .previewDisplayName("Light, single")
        ScrollView {
            CommentsView(
                items: [.preview, .preview, .preview],
                reportClbk: { _ in },
                deleteClbk: { _ in },
                editClbk: { _ in },
                isCreatingComment: .constant(false)
            )
        }
        .previewDisplayName("Light, multiple")
        Group {
            ScrollView {
                CommentsView(
                    items: [.preview],
                    reportClbk: { _ in },
                    deleteClbk: { _ in },
                    editClbk: { _ in },
                    isCreatingComment: .constant(false)
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
                    editClbk: { _ in },
                    isCreatingComment: .constant(false)
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
#endif
