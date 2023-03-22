import SwiftUI

public extension Color {
    /// Вспомогательный
    static let swBlack = Color("SWBlack", bundle: .module)
    /// Фон
    static let swBackground = Color("swBackground", bundle: .module)
    /// Фон карточек
    static let swCardBackground = Color("swCardBackground", bundle: .module)
    /// Подписи/иконки
    static let swSmallElements = Color("swSmallElements", bundle: .module)
    #warning("Поправить цвет для светлой темы")
    /// Разделители
    static let swSeparators = Color("swSeparators", bundle: .module)
    /// Основной текст
    static let swWhite = Color("SWWhite", bundle: .module)
    /// `AccentColor` для приложения
    static let swAccent = Color("swAccent", bundle: .module)
    /// Нажатые кнопки
    static let swButtonPressed = Color("swButtonPressed", bundle: .module)
    /// Неактивные кнопки
    static let swButtonDisabled = Color("swButtonDisabled", bundle: .module)
    /// Вторичные кнопки
    static let swSecondaryButton = Color("swSecondaryButton", bundle: .module)
    /// Вторичные кнопки в нажатом состоянии
    static let swSecondaryButtonPressed = Color("swSecondaryButtonPressed", bundle: .module)
    /// Ошибки
    static let swError = Color("swError", bundle: .module)
}
