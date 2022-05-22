import SwiftUI

/// Список комментариев
struct Comments: View {
    let items: [Comment]
    let deleteClbk: (Int) -> Void
    let editClbk: (Comment) -> Void

    var body: some View {
        Section("Комментарии") {
            List(items) { comment in
                CommentViewCell(
                    model: comment,
                    deleteClbk: deleteClbk,
                    editClbk: editClbk
                )
            }
        }
    }
}

struct Comments_Previews: PreviewProvider {
    static var previews: some View {
        Comments(items: [.mock, .mock], deleteClbk: {_ in}, editClbk: {_ in})
    }
}
