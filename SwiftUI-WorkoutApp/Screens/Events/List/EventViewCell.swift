import SwiftUI
import SWModels

struct EventViewCell: View {
    let event: EventResponse

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            CachedImage(
                url: event.previewImageURL,
                mode: .eventListItem
            )
            VStack(alignment: .leading, spacing: 4) {
                Text(event.formattedTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .fixedSize(horizontal: false, vertical: true)
                Text(event.shortAddress)
                    .font(.caption)
                Text(event.eventDateString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#if DEBUG
struct EventViewCell_Previews: PreviewProvider {
    static var previews: some View {
        EventViewCell(event: .preview)
            .previewLayout(.sizeThatFits)
    }
}
#endif
