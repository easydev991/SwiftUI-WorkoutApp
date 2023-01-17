import SwiftUI

struct UserViewCell: View {
    let model: UserModel

    var body: some View {
        HStack(spacing: 16) {
            CachedImage(url: model.imageURL)
            VStack(alignment: .leading) {
                Text(model.name)
                    .fontWeight(.medium)
                Text(model.shortAddress)
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
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
