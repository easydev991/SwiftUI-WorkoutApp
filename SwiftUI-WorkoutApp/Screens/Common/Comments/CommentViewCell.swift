import SwiftUI
import NetworkStatus

struct CommentViewCell: View {
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    let model: CommentResponse
    let reportClbk: (CommentResponse) -> Void
    let deleteClbk: (Int) -> Void
    let editClbk: (CommentResponse) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 16) {
                CachedImage(url: model.user?.avatarURL)
                nameDate
                Spacer()
                if network.isConnected {
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
            if isCommentByMainUser {
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
            } else {
                Button(role: .destructive) {
                    reportClbk(model)
                } label: {
                    Label("Пожаловаться", systemImage: "exclamationmark.triangle")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .onTapGesture { hapticFeedback(.rigid) }
    }

    var isCommentByMainUser: Bool {
        model.user?.userID == defaults.mainUserInfo?.userID
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
            reportClbk: { _ in },
            deleteClbk: { _ in },
            editClbk: { _ in }
        )
        .environmentObject(NetworkStatus())
        .environmentObject(DefaultsService())
        .previewLayout(.sizeThatFits)
    }
}
#endif
