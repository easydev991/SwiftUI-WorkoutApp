import SWDesignSystem
import SwiftUI
import SWModels

/// Список комментариев
struct CommentsView: View {
    @Environment(\.userFlags) private var userFlags
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @State private var userModel: UserResponse?
    let mainUserId: Int?
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
                                isCommentByMainUser: comment.user?.id == mainUserId,
                                isNetworkConnected: isNetworkConnected,
                                action: { option in
                                    switch option {
                                    case .report:
                                        reportClbk(comment)
                                    case .edit:
                                        editClbk(comment)
                                    case .delete:
                                        deleteClbk(comment.id)
                                    case .openProfile:
                                        if let user = comment.user, userFlags.isAuthorized {
                                            userModel = user
                                        }
                                    }
                                }
                            )
                            .withDivider(if: index != items.endIndex - 1)
                        }
                    }
                }
            }
            if userFlags.isAuthorized {
                Button("Добавить комментарий", action: createCommentClbk)
                    .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
            }
        }
        .navigationDestination(isPresented: $userModel.mappedToBool()) {
            if let userModel {
                UserDetailsScreen(for: userModel)
            }
        }
    }
}

#if DEBUG
#Preview("Single") {
    CommentsView(
        mainUserId: nil,
        items: [.preview],
        reportClbk: { _ in },
        deleteClbk: { _ in },
        editClbk: { _ in },
        createCommentClbk: {}
    )
    .padding(.horizontal)
}

#Preview("Multiple") {
    CommentsView(
        mainUserId: nil,
        items: [.preview, .preview, .preview],
        reportClbk: { _ in },
        deleteClbk: { _ in },
        editClbk: { _ in },
        createCommentClbk: {}
    )
    .padding(.horizontal)
}
#endif
