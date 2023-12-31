import SWDesignSystem
import SwiftUI
import SWModels

/// Отображает текст с ошибкой определения геолокации пользователя
/// и кнопку для перехода в настройки приложения
struct LocationSettingReminderView: View {
    let message: String
    let isHidden: Bool

    var body: some View {
        VStack(spacing: 12) {
            Text(.init(message))
                .foregroundStyle(Color.swMainText)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.vertical, 12)
                .padding(.horizontal, 30)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.swBackground)
                        .withShadow()
                }
            Button("Открыть настройки") {
                URLOpener.open(URL(string: UIApplication.openSettingsURLString))
            }
            .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
        }
        .padding(.horizontal)
        .padding(.bottom, 32)
        .opacity(isHidden ? 0 : 1)
        .animation(.easeInOut, value: isHidden)
    }
}

#Preview {
    LocationSettingReminderView(
        message: Constants.Alert.needLocationPermission,
        isHidden: false
    )
}
