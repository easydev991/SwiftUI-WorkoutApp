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
    func titleText(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .foregroundColor(.swMainText)
            .multilineTextAlignment(.center)
            .padding(.bottom, 6)
    }

    @ViewBuilder
    var hintTextIfAvailable: some View {
        if isHintAvailable {
            Text(.init(Constants.Alert.eventCreationRule))
                .foregroundColor(.swMainText)
                .font(.footnote.weight(.medium))
                .multilineTextAlignment(.center)
        }
    }

    var actionButtonTitle: LocalizedStringKey {
        switch mode {
        case .events:
            hasSportsGrounds && isAuthorized
                ? "Создать мероприятие"
                : "Выбрать площадку"
        case .dialogs:
            hasFriends ? "Открыть список друзей" : "Найти пользователя"
        case .journals: "Создать дневник"
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
    var message: LocalizedStringKey {
        switch self {
        case .events:
            "Нет запланированных\nмероприятий"
        case .dialogs:
            "Чатов пока нет"
        case .journals:
            "Дневников пока нет"
        }
    }
}

#if DEBUG
#Preview {
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
#endif
