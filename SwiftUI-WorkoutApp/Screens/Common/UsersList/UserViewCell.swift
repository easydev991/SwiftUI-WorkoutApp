import DesignSystem
import SwiftUI
import SWModels

struct UserViewCell: View {
    let model: UserModel

    var body: some View {
        UserRowView(
            mode: .regular(
                .init(
                    imageURL: model.imageURL,
                    name: model.name,
                    address: model.shortAddress
                )
            )
        )
    }
}

#if DEBUG
struct UserViewCell_Previews: PreviewProvider {
    static var previews: some View {
        UserViewCell(model: .preview)
            .previewLayout(.sizeThatFits)
    }
}
#endif
