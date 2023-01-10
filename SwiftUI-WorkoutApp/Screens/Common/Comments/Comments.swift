import SwiftUI

/// Список комментариев
struct Comments: View {
    let items: [Comment]
    let reportClbk: (Comment) -> Void
    let deleteClbk: (Int) -> Void
    let editClbk: (Comment) -> Void

    var body: some View {
        Section("Комментарии") {
            List(items) { comment in
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
        Form {
            Comments(
                items: [.preview, .preview],
                reportClbk: { _ in },
                deleteClbk: { _ in },
                editClbk: { _ in }
            )
        }
        .environmentObject(DefaultsService())
        .environmentObject(CheckNetworkService())
    }
}
#endif
