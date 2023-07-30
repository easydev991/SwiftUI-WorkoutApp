import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels

/// Заглушка на случай, когда нет контента
struct EmptyContentView: View {
    let mode: Mode
    let isAuthorized: Bool
    let hasFriends: Bool
    let hasSportsGrounds: Bool
    let isNetworkConnected: Bool
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            if isNetworkConnected {
                titleText(mode.message)
                if isAuthorized {
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
            .foregroundColor(.swMainText)
            .multilineTextAlignment(.center)
            .padding(.bottom, 6)
    }

    @ViewBuilder
    var hintTextIfAvailable: some View {
        if isHintAvailable {
            Text(Constants.Alert.eventCreationRule)
                .foregroundColor(.swMainText)
                .font(.footnote.weight(.medium))
                .multilineTextAlignment(.center)
        }
    }

    var actionButtonTitle: String {
        switch mode {
        case .events:
            return hasSportsGrounds && isAuthorized
                ? "Создать мероприятие"
                : "Выбрать площадку"
        case .dialogs:
            return hasFriends ? "Открыть список друзей" : "Найти пользователя"
        case .journals: return "Создать дневник"
        }
    }

    var isHintAvailable: Bool {
        mode == .events && isAuthorized && !hasSportsGrounds
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
        VStack {
            ForEach(EmptyContentView.Mode.allCases, id: \.self) { mode in
                EmptyContentView(
                    mode: mode,
                    isAuthorized: true,
                    hasFriends: true,
                    hasSportsGrounds: true,
                    isNetworkConnected: true,
                    action: {}
                )
                Divider()
            }
            EmptyContentView(
                mode: .dialogs,
                isAuthorized: true,
                hasFriends: true,
                hasSportsGrounds: true,
                isNetworkConnected: false,
                action: {}
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
