import SwiftUI
import Utils

struct SportsGroundViewCell: View {
    let model: SportsGround

    var body: some View {
        HStack(spacing: 16) {
            CacheImageView(
                url: model.previewImageURL,
                mode: .groundListItem
            )
            VStack(alignment: .leading, spacing: 4) {
                Text(model.longTitle)
                    .fontWeight(.medium)
                Text(model.address.valueOrEmpty)
                    .font(.caption)
                Text(model.usersTrainHereText)
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
}

struct SportsGroundsForUserView_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundViewCell(model: .mock)
            .previewLayout(.sizeThatFits)
    }
}
