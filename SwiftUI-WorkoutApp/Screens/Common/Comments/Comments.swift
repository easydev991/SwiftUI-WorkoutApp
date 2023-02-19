import NetworkStatus
import SwiftUI
import SWModels

/// Список комментариев
struct Comments: View {
    let items: [CommentResponse]
    let reportClbk: (CommentResponse) -> Void
    let deleteClbk: (Int) -> Void
    let editClbk: (CommentResponse) -> Void

    var body: some View {
        Section("Комментарии") {
            ForEach(items) { comment in
                CommentViewCell(
                    model: comment,
                    reportClbk: reportClbk,
                    deleteClbk: deleteClbk,
                    editClbk: editClbk
                )
            }
        }
    }
}

#if DEBUG
struct Comments_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Comments(
                items: [.preview, .preview],
                reportClbk: { _ in },
                deleteClbk: { _ in },
                editClbk: { _ in }
            )
        }
        .environmentObject(DefaultsService())
        .environmentObject(NetworkStatus())
    }
}
#endif
