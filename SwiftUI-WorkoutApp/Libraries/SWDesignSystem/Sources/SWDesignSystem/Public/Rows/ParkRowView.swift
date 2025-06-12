import SwiftUI

/// Вьюшка с площадкой (в списке площадок)
public struct ParkRowView: View {
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
                parkTitle
                    .padding(.bottom, 2)
                addressIfNeeded
                participantsInfo
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .insideCardBackground()
    }
}

private extension ParkRowView {
    var leadingImage: some View {
        CachedImage(url: imageURL, mode: .parkListItem)
    }

    var parkTitle: some View {
        Text(title)
            .foregroundStyle(Color.swMainText)
            .font(.headline)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }

    @ViewBuilder
    var addressIfNeeded: some View {
        if let address {
            HStack(spacing: 6) {
                SystemImageWithFrame(Icons.Regular.location.rawValue)
                makeSubtitleView(with: address)
            }
        }
    }

    var participantsInfo: some View {
        HStack(spacing: 6) {
            SystemImageWithFrame(Icons.Regular.person.rawValue)
            makeSubtitleView(with: usersTrainHereText)
        }
    }

    func makeSubtitleView(with text: String) -> some View {
        Text(text)
            .foregroundStyle(Color.swSmallElements)
            .font(.subheadline)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 12) {
        Button {
            print("tap!")
        } label: {
            ParkRowView(
                imageURL: URL(string: "https://workout.su/uploads/userfiles/измайлово.jpg"),
                title: "N° 3 Легендарная / Средняя",
                address: "м. Партизанская, улица 2-я Советская",
                usersTrainHereText: "Тренируются 5 человек"
            )
        }
        ParkRowView(
            imageURL: URL(string: "https://workout.su/uploads/userfiles/измайлово.jpg"),
            title: "N° 3 Легендарная / Средняя",
            address: nil,
            usersTrainHereText: "Тренируются 5 человек"
        )
        ParkRowView(
            imageURL: URL(string: "https://workout.su/uploads/userfiles/измайлово.jpg"),
            title: "N° 3 Легендарная / Средняя",
            address: "м. Партизанская, улица 2-я Советская",
            usersTrainHereText: "Здесь пока никто не тренируется"
        )
    }
    .padding(.horizontal)
}
#endif
