import DesignSystem
import SwiftUI
import SWModels

struct FriendRequestCell: View {
    let model: UserModel
    let acceptClbk: (Int) -> Void
    let declineClbk: (Int) -> Void

    var body: some View {
        UserRowView(
            mode: .friendRequest(
                .init(
                    imageURL: model.imageURL,
                    name: model.name,
                    address: model.shortAddress
                ),
                .init(
                    accept: { acceptClbk(model.id) },
                    reject: { declineClbk(model.id) }
                )
            )
        )
    }
}

#if DEBUG
struct FriendRequestCell_Previews: PreviewProvider {
    static var previews: some View {
        FriendRequestCell(
            model: .emptyValue,
            acceptClbk: { _ in },
            declineClbk: { _ in }
        )
        .previewLayout(.sizeThatFits)
    }
}
#endif
