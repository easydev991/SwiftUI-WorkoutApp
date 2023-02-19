import SwiftUI
import SWModels
import Utils

struct SportsGroundViewCell: View {
    let model: SportsGround

    var body: some View {
        HStack(spacing: 16) {
            CachedImage(
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

#if DEBUG
struct SportsGroundsForUserView_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundViewCell(model: .preview)
            .previewLayout(.sizeThatFits)
    }
}
#endif
