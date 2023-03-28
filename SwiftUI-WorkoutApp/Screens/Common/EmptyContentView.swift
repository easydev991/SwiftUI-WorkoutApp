import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels

/// Заглушка на случай, когда нет контента
struct EmptyContentView: View {
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    let mode: Mode
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            if network.isConnected {
                titleText(mode.message)
                if defaults.isAuthorized {
                    Button(actionButtonTitle, action: action)
                        .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
                }
            } else {
                titleText("Нет соединения с сетью")
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 60))
            }
            hintTextIfAvailable
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

private extension EmptyContentView {
    func titleText(_ text: String) -> some View {
        Text(text)
            .foregroundColor(.swWhite)
            .multilineTextAlignment(.center)
            .padding(.bottom, 6)
    }

    @ViewBuilder
    var hintTextIfAvailable: some View {
        if isHintAvailable {
            Text(Constants.Alert.eventCreationRule)
                .foregroundColor(.swWhite)
                .font(.footnote.weight(.medium))
                .multilineTextAlignment(.center)
        }
    }

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
            return "Нет запланированных\nмероприятий"
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
                .previewDisplayName(mode.message)
        }
        .environmentObject(NetworkStatus())
        .environmentObject(DefaultsService())
        .previewLayout(.sizeThatFits)
    }
}
#endif
