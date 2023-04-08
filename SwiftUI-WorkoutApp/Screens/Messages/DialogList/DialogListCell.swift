import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels

struct DialogListCell: View {
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    private let model: DialogResponse

    init(model: DialogResponse) {
        self.model = model
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            CachedImage(
                url: model.anotherUserImageURL,
                mode: .genericListItem
            )
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Text(model.anotherUserName.valueOrEmpty)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    Text(model.lastMessageDateString)
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text(model.lastMessageFormatted)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    Spacer()
                    if model.unreadMessagesCount > .zero {
                        Image(systemName: "\(model.unreadMessagesCount).circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

#if DEBUG
struct DialogListCell_Previews: PreviewProvider {
    static var previews: some View {
        DialogListCell(model: .preview)
            .environmentObject(NetworkStatus())
            .previewLayout(.sizeThatFits)
    }
}
#endif
