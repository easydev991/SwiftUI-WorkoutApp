//
//  LocationSettingReminderView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Oleg991 on 16.10.2023.
//

import SwiftUI
import DesignSystem
import SWModels

/// Отображает текст с ошибкой определения геолокации пользователя
/// и кнопку для перехода в настройки приложения
struct LocationSettingReminderView: View {
    private let settingsStringURL = UIApplication.openSettingsURLString
    let message: String
    let isHidden: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Text(.init(message))
                .foregroundColor(.swMainText)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.vertical, 12)
                .padding(.horizontal, 30)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .foregroundColor(.swBackground)
                        .withShadow()
                }
            Button("Открыть настройки") {
                URLOpener.open(URL(string: settingsStringURL))
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
