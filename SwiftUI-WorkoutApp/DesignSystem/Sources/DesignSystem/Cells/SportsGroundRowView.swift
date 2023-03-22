import CachedAcyncImage
import SwiftUI

public struct SportsGroundRowView: View {
    private let imageURL: URL?
    private let title: String
    private let address: String?
    private let usersTrainHereText: String

    public init(
        imageURL: URL?,
        title: String,
        address: String?,
        usersTrainHereText: String
    ) {
        self.imageURL = imageURL
        self.title = title
        self.address = address
        self.usersTrainHereText = usersTrainHereText
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            leadingImage
            VStack(alignment: .leading, spacing: 6) {
                sportsGroundTitle
                addressIfNeeded
                participantsInfo
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .foregroundColor(.swCardBackground)
                .withShadow()
        }
    }
}

private extension SportsGroundRowView {
    var leadingImage: some View {
        CachedAsyncImage(
            url: imageURL,
            content: { image in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            },
            placeholder: {
                Image.defaultWorkoutImage
                    .resizable()
                    .scaledToFit()
            }
        )
        .frame(width: 74, height: 74)
        .cornerRadius(12)
    }

    var sportsGroundTitle: some View {
        Text(title)
            .foregroundColor(.swWhite)
            .font(.headline)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }

    @ViewBuilder
    var addressIfNeeded: some View {
        if let address {
            HStack(spacing: 4) {
                Image.locationIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
                    .foregroundColor(.swAccent)
                Text(address)
                    .foregroundColor(.swSmallElements)
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
    }

    var participantsInfo: some View {
        HStack(spacing: 4) {
            Image(systemName: Icons.Misc.personInCircle.rawValue)
                .foregroundColor(.swAccent)
            Text(usersTrainHereText)
                .foregroundColor(.swSmallElements)
                .font(.caption)
                .lineLimit(1)
        }
    }
}

#if DEBUG
struct SportsGroundRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            SportsGroundRowView(
                imageURL: URL(string: "https://workout.su/uploads/userfiles/измайлово.jpg")!,
                title: "N° 3 Легендарная / Средняя",
                address: "м. Партизанская, улица 2-я Советская",
                usersTrainHereText: "Тренируется 5 чел."
            )
            SportsGroundRowView(
                imageURL: URL(string: "https://workout.su/uploads/userfiles/измайлово.jpg")!,
                title: "N° 3 Легендарная / Средняя",
                address: nil,
                usersTrainHereText: "Тренируется 5 чел."
            )
        }
    }
}
#endif
