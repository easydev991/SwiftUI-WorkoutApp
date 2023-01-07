import SwiftUI

/// Заглушка на случай, когда нет контента
struct EmptyContentView: View {
    @EnvironmentObject private var network: CheckNetworkService
    @EnvironmentObject private var defaults: DefaultsService
    let mode: Mode
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text(mode.message)
                .font(.title2)
                .multilineTextAlignment(.center)
            if network.isConnected {
                Button(action: action) {
                    RoundedButtonLabel(title: actionButtonTitle)
                }
                .opacity(defaults.isAuthorized ? 1 : 0)
            } else {
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 60))
            }
            if isHintAvailable {
                Text(Constants.Alert.eventCreationRule)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
    }
}

private extension EmptyContentView {
    var actionButtonTitle: String {
        switch mode {
        case .events:
            return defaults.hasSportsGrounds && defaults.isAuthorized
            ? "Создать мероприятие"
            : "Выбрать площадку"
        case .dialogs:
            return defaults.hasFriends ? "Открыть список друзей" : "Найти пользователя"
        case .journals: return "Создать дневник"
        }
    }

    var isHintAvailable: Bool {
        mode == .events && defaults.isAuthorized && !defaults.hasSportsGrounds
    }
}

extension EmptyContentView {
    enum Mode: CaseIterable {
        case events, dialogs, journals
    }
}

private extension EmptyContentView.Mode {
    var message: String {
        switch self {
        case .events:
            return "Нет запланированных мероприятий"
        case .dialogs:
            return "Чатов пока нет"
        case .journals:
            return "Дневников пока нет"
        }
    }
}

#if DEBUG
struct EmptyContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(EmptyContentView.Mode.allCases, id: \.self) { mode in
            EmptyContentView(mode: mode, action: {})
        }
        .environmentObject(CheckNetworkService())
        .environmentObject(DefaultsService())
        .previewLayout(.sizeThatFits)
    }
}
#endif
