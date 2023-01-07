import SwiftUI

struct CommentViewCell: View {
    @EnvironmentObject private var network: CheckNetworkService
    @EnvironmentObject private var defaults: DefaultsService
    let model: Comment
    let deleteClbk: (Int) -> Void
    let editClbk: (Comment) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 16) {
                CacheImageView(url: model.user?.avatarURL)
                nameDate
                Spacer()
                if isMenuAvailable {
                    menuButton
                }
            }
            Text(.init(model.formattedBody))
                .fixedSize(horizontal: false, vertical: true)
                .tint(.blue)
                .textSelection(.enabled)
        }
    }
}

private extension CommentViewCell {
    var nameDate: some View {
        VStack(alignment: .leading) {
            Text((model.user?.userName).valueOrEmpty)
                .fontWeight(.medium)
                .textSelection(.enabled)
            Text(model.formattedDateString)
                .foregroundColor(.secondary)
                .font(.caption)
                .padding(.bottom, 4)
        }
    }

    var menuButton: some View {
        Menu {
            Button {
                editClbk(model)
            } label: {
                Label("Изменить", systemImage: "rectangle.and.pencil.and.ellipsis")
            }
            Button(role: .destructive) {
                deleteClbk(model.id)
            } label: {
                Label("Удалить", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .onTapGesture { hapticFeedback(.rigid) }
    }

    var isMenuAvailable: Bool {
        model.user?.userID == defaults.mainUserInfo?.userID
        && network.isConnected
    }
}

#if DEBUG
struct SportsGroundCommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentViewCell(
            model: .init(
                id: .zero,
                body: "Test comment",
                date: "2013-01-16T03:35:54+04:00",
                user: .preview
            ),
            deleteClbk: { _ in },
            editClbk: { _ in }
        )
        .environmentObject(CheckNetworkService())
        .environmentObject(DefaultsService())
        .previewLayout(.sizeThatFits)
    }
}
#endif
