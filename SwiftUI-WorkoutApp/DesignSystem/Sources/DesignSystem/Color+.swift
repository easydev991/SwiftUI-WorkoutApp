import SwiftUI

public extension Color {
    /// Вспомогательный
    static let swBlack = Color("SWBlack", bundle: .module)
    /// Фон
    static let black2 = Color("Black2", bundle: .module)
    /// Фон карточек
    static let gray1 = Color("Gray1", bundle: .module)
    /// Подписи/иконки
    static let gray2 = Color("Gray2", bundle: .module)
    #warning("Поправить цвет для светлой темы")
    /// Разделители
    static let gray3 = Color("Gray3", bundle: .module)
    /// Основной текст
    static let swWhite = Color("SWWhite", bundle: .module)
    /// `AccentColor` для приложения
    static let swGreen = Color("SWGreen", bundle: .module)
    /// Нажатые кнопки
    static let green2 = Color("Green2", bundle: .module)
    /// Неактивные кнопки
    static let green3 = Color("Green3", bundle: .module)
    /// Вторичные кнопки
    static let green4 = Color("Green4", bundle: .module)
    /// Ошибки
    static let swRed = Color("SWRed", bundle: .module)
}
