import SwiftUI

/// Заглушка на случай, когда нет контента
struct EmptyContentView: View {
    @EnvironmentObject private var defaults: DefaultsService
    let mode: Mode

    var body: some View {
        content
            .padding()
    }
}

extension EmptyContentView {
    enum Mode {
        case events, journals, messages
    }
}

private extension EmptyContentView.Mode {
    var info: Info {
        switch self {
        case .events:
            return .init(message: "Нет запланированных мероприятий", buttonTitle: "Создать мероприятие")
        case .journals:
            return .init(message: "Дневников пока нет", buttonTitle: "Создать дневник")
        case .messages:
            return .init(message: "Чатов пока нет", buttonTitle: "Открыть список друзей")
        }
    }

    struct Info {
        let message: String
        let buttonTitle: String
    }
}

private extension EmptyContentView {
    var content: some View {
        VStack(spacing: 16) {
            Spacer()
            Text(mode.info.message)
                .font(.title2)
                .multilineTextAlignment(.center)
            NavigationLink {
                switch mode {
                case .events:
                    EventFormView(for: .regularCreate)
                case .journals:
                    Text("Создать дневник")
                case .messages:
                    UsersListView(mode: .friends(userID: defaults.mainUserID))
                        .navigationTitle("Друзья")
                }
            } label: {
                Text(mode.info.buttonTitle)
                    .roundedRectangleStyle()
            }
            .opacity(defaults.isAuthorized ? 1 : .zero)
            Spacer()
        }
    }
}

struct EmptyContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EmptyContentView(mode: .events)
            EmptyContentView(mode: .journals)
            EmptyContentView(mode: .messages)
        }
        .environmentObject(DefaultsService())
    }
}
