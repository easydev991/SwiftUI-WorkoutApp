import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels

/// Список комментариев
struct CommentsView: View {
    let items: [CommentResponse]
    let reportClbk: (CommentResponse) -> Void
    let deleteClbk: (Int) -> Void
    let editClbk: (CommentResponse) -> Void

    var body: some View {
        VStack(spacing: 4) {
            SectionHeaderView("Комментарии")
            VStack(spacing: 0) {
                ForEach(commentsTuple, id: \.0) { index, comment in
                    VStack(spacing: 12) {
                        CommentViewCell(
                            model: comment,
                            reportClbk: reportClbk,
                            deleteClbk: deleteClbk,
                            editClbk: editClbk
                        )
                        dividerIfNeeded(at: index)
                    }
                }
            }
            .insideCardBackground(padding: 0)
        }
    }
}

private extension CommentsView {
    var commentsTuple: [(Int, CommentResponse)] {
        .init(zip(items.indices, items))
    }

    @ViewBuilder
    func dividerIfNeeded(at index: Int) -> some View {
        if index != commentsTuple.endIndex - 1 {
            Divider()
                .background(Color.swSeparators)
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
                .padding(.horizontal)
            }
            .previewDisplayName("Light, single")
            ScrollView {
                CommentsView(
                    items: [.preview, .preview, .preview],
                    reportClbk: { _ in },
                    deleteClbk: { _ in },
                    editClbk: { _ in }
                )
                .padding(.horizontal)
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
                    .padding(.horizontal)
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
