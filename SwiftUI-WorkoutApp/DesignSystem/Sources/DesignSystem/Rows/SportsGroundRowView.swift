import CachedAsyncImage991
import SwiftUI

/// Вьюшка с площадкой (в списке площадок)
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
                    .padding(.bottom, 2)
                addressIfNeeded
                participantsInfo
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .insideCardBackground()
    }
}

private extension SportsGroundRowView {
    var leadingImage: some View {
        CachedImage(url: imageURL, mode: .groundListItem)
    }

    var sportsGroundTitle: some View {
        Text(title)
            .foregroundColor(.swMainText)
            .font(.headline)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }

    @ViewBuilder
    var addressIfNeeded: some View {
        if let address {
            HStack(spacing: 6) {
                Image(systemName: Icons.Regular.location.rawValue)
                    .foregroundColor(.swAccent)
                makeSubtitleView(with: address)
            }
        }
    }

    var participantsInfo: some View {
        HStack(spacing: 6) {
            Image(systemName: Icons.Regular.personInCircle.rawValue)
                .foregroundColor(.swAccent)
            makeSubtitleView(with: usersTrainHereText)
        }
    }

    func makeSubtitleView(with text: String) -> some View {
        Text(text)
            .foregroundColor(.swSmallElements)
            .font(.subheadline)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }
}

#if DEBUG
#Preview {
    Group {
        ForEach(ColorScheme.allCases, id: \.self) { scheme in
            VStack(spacing: 12) {
                SportsGroundRowView(
                    imageURL: URL(string: "https://workout.su/uploads/userfiles/измайлово.jpg"),
                    title: "N° 3 Легендарная / Средняя",
                    address: "м. Партизанская, улица 2-я Советская",
                    usersTrainHereText: "Тренируются 5 человек"
                )
                SportsGroundRowView(
                    imageURL: URL(string: "https://workout.su/uploads/userfiles/измайлово.jpg"),
                    title: "N° 3 Легендарная / Средняя",
                    address: nil,
                    usersTrainHereText: "Тренируются 5 человек"
                )
                SportsGroundRowView(
                    imageURL: URL(string: "https://workout.su/uploads/userfiles/измайлово.jpg"),
                    title: "N° 3 Легендарная / Средняя",
                    address: "м. Партизанская, улица 2-я Советская",
                    usersTrainHereText: "Здесь пока никто не тренируется"
                )
            }
            .padding()
            .background(Color.swBackground)
            .environment(\.colorScheme, scheme)
            .previewDisplayName(scheme == .dark ? "Dark" : "Light")
        }
    }
    .previewLayout(.sizeThatFits)
}
#endif
