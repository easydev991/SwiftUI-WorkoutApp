import SWDesignSystem
import SwiftUI
import SWModels

/// Экран со списком участников мероприятия/тренирующихся на площадке
struct ParticipantsScreen: View {
    @EnvironmentObject private var defaults: DefaultsService
    let mode: Mode

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(list) { user in
                    NavigationLink(destination: UserDetailsScreen(for: user)) {
                        makeLabelForRow(with: user)
                    }
                    .disabled(user.id == defaults.mainUserInfo?.id)
                }
            }
            .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func makeLabelForRow(with user: UserResponse) -> some View {
        UserRowView(
            mode: .regular(
                .init(
                    imageURL: user.avatarURL,
                    name: user.userName ?? "",
                    address: SWAddress(user.countryID, user.cityID)?.address ?? ""
                )
            )
        )
    }
}

extension ParticipantsScreen {
    enum Mode {
        /// Участники мероприятия
        case event(list: [UserResponse])
        /// Тренирующиеся на площадке
        case park(list: [UserResponse])
    }
}

private extension ParticipantsScreen {
    var title: LocalizedStringKey {
        switch mode {
        case .event:
            "Участники мероприятия"
        case .park:
            "Здесь тренируются"
        }
    }

    var list: [UserResponse] {
        switch mode {
        case let .event(users), let .park(users):
            users
        }
    }
}

#if DEBUG
#Preview("Мероприятие") {
    ParticipantsScreen(mode: .event(list: [.preview]))
}

#Preview("Площадка") {
    ParticipantsScreen(mode: .park(list: [.preview]))
}
#endif
