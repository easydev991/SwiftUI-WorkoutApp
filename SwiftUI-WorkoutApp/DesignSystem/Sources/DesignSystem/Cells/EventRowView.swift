import CachedAcyncImage
import SwiftUI

public struct EventRowView: View {
    private let imageURL: URL?
    private let title: String
    private let dateTimeText: String
    private let locationText: String?

    public init(
        imageURL: URL?,
        title: String,
        dateTimeText: String,
        locationText: String?
    ) {
        self.imageURL = imageURL
        self.title = title
        self.dateTimeText = dateTimeText
        self.locationText = locationText
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            leadingImage
            VStack(alignment: .leading, spacing: 10) {
                eventTitle
                HStack(spacing: 10) {
                    eventDateTimeInfo
                    locationInfoIfNeeded
                    Spacer()
                }
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

private extension EventRowView {
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

    var eventTitle: some View {
        Text(title)
            .foregroundColor(.swWhite)
            .font(.headline)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }

    var eventDateTimeInfo: some View {
        HStack(spacing: 4) {
            Image(systemName: Icons.Misc.clock.rawValue)
                .foregroundColor(.swAccent)
            Text(dateTimeText)
                .foregroundColor(.swSmallElements)
                .font(.caption)
                .lineLimit(1)
        }
        .fixedSize(horizontal: true, vertical: false)
    }

    @ViewBuilder
    var locationInfoIfNeeded: some View {
        if let locationText {
            HStack(spacing: 4) {
                Image.locationIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
                    .foregroundColor(.swAccent)
                Text(locationText)
                    .foregroundColor(.swSmallElements)
                    .font(.caption)
                    .lineLimit(1)
            }
        }
    }
}

#if DEBUG
struct EventRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            EventRowView(
                imageURL: nil,
                title: "Открытая воскресная тренировка #3 в 2023 году (участники)",
                dateTimeText: "22 янв, 12:00",
                locationText: "Россия, Москва"
            )
            EventRowView(
                imageURL: nil,
                title: "Открытая воскресная тренировка #3 в 2023 году (участники)",
                dateTimeText: "22 янв, 12:00",
                locationText: "Россия, Москва"
            )
            .environment(\.colorScheme, .dark)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
