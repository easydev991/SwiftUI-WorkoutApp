import SwiftUI

struct UserViewCell: View {
    let model: UserModel

    var body: some View {
        HStack(spacing: 16) {
            CacheImageView(url: model.imageURL)
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

struct UserViewRow_Previews: PreviewProvider {
    static var previews: some View {
        UserViewCell(model: .emptyValue)
    }
}
