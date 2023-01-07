import SwiftUI

struct FriendRequestCell: View {
    let model: UserModel
    let acceptClbk: (Int) -> Void
    let declineClbk: (Int) -> Void

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 16) {
                    CacheImageView(url: model.imageURL)
                    VStack(alignment: .leading) {
                        Text(model.name)
                        Text(model.shortAddress)
                    }
                }
                HStack(spacing: 16) {
                    Button(action: accept) {
                        Text("Принять")
                    }
                    .tint(.blue)
                    Button(role: .destructive, action: decline) {
                        Text("Отклонить")
                    }
                    .tint(.red)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
            }
        }
    }
}

private extension FriendRequestCell {
    func accept() { acceptClbk(model.id) }
    func decline() { declineClbk(model.id) }
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
