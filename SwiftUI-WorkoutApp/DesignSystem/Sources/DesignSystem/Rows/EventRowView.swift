import CachedAsyncImage991
import SwiftUI

/// Вьюшка с мероприятием (в списке мероприятий)
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
            VStack(alignment: .leading, spacing: 8) {
                eventTitle
                eventDateTimeInfo
                locationInfoIfNeeded
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .insideCardBackground()
    }
}

private extension EventRowView {
    var leadingImage: some View {
        CachedImage(url: imageURL, mode: .eventListItem)
    }

    var eventTitle: some View {
        Text(title)
            .foregroundColor(.swMainText)
            .font(.headline)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }

    var eventDateTimeInfo: some View {
        HStack(spacing: 6) {
            Image(systemName: Icons.Regular.clock.rawValue)
                .foregroundColor(.swAccent)
            Text(dateTimeText)
                .foregroundColor(.swSmallElements)
                .font(.subheadline)
                .lineLimit(1)
        }
        .fixedSize(horizontal: true, vertical: false)
    }

    @ViewBuilder
    var locationInfoIfNeeded: some View {
        if let locationText {
            HStack(spacing: 6) {
                Image(systemName: Icons.Regular.location.rawValue)
                    .foregroundColor(.swAccent)
                Text(locationText)
                    .foregroundColor(.swSmallElements)
                    .font(.subheadline)
                    .lineLimit(1)
            }
        }
    }
}

#if DEBUG
#Preview {
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
#endif
