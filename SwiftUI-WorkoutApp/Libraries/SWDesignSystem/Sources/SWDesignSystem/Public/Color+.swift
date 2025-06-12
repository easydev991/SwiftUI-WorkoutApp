import SwiftUI

public extension Color {
    /// Фон
    static let swBackground = Color(.swBackground)
    /// Фон карточек
    static let swCardBackground = Color(.swCardBackground)
    /// Подписи/иконки
    static let swSmallElements = Color(.swSmallElements)
    /// Разделители
    static let swSeparators = Color(.swSeparators)
    /// Основной текст
    static let swMainText = Color(.swMainText)
    /// `AccentColor` для приложения
    static let swAccent = Color(.swAccent)
    /// Цвет текста в `filled`-кнопке
    static let swFilledButtonText = Color(.swFilledButtonText)
    /// Нажатые `filled`-кнопки
    static let swFilledButtonPressed = Color(.swFilledButtonPressed)
    /// Неактивные кнопки
    static let swDisabledButton = Color(.swDisabledButton)
    /// Цвет текста неактивных кнопок
    static let swDisabledButtonText = Color(.swDisabledButtonText)
    /// `tinted`-кнопки
    static let swTintedButton = Color(.swTintedButton)
    /// Нажатые `tinted`-кнопки
    static let swTintedButtonPressed = Color(.swTintedButtonPressed)
    /// Цвет кнопки добавления фото
    static let swAddPhotoButton = Color(.swAddPhotoButton)
    /// Цвет текста и иконок в поле для поиска
    static let swSearchForeground = Color(.swSearchForeground)
    /// Цвет фона в поле для поиска
    static let swSearchBackground = Color(.swSearchBackground)
    /// Ошибки
    static let swError = Color(.swError)
    /// Цвет таббара
    static let swTabBar = Color(.swTabBar)
}

#if DEBUG
#Preview {
    let colors: [Color] = [
        .swBackground, .swCardBackground, .swSmallElements, .swSeparators,
        .swMainText, .swAccent, .swFilledButtonText, .swFilledButtonPressed,
        .swDisabledButton, .swDisabledButtonText, .swTintedButton,
        .swTintedButtonPressed, .swAddPhotoButton, .swError, .swTabBar
    ]
    return ScrollView {
        VStack(spacing: 4) {
            ForEach(colors, id: \.self) { color in
                Circle()
                    .fill(color)
                    .frame(width: 50, height: 50)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
#endif
