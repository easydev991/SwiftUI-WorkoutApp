import SwiftUI

public extension Color {
    /// Фон
    static let swBackground = Color("swBackground", bundle: .module)
    /// Фон карточек
    static let swCardBackground = Color("swCardBackground", bundle: .module)
    /// Подписи/иконки
    static let swSmallElements = Color("swSmallElements", bundle: .module)
    /// Разделители
    static let swSeparators = Color("swSeparators", bundle: .module)
    /// Основной текст
    static let swMainText = Color("swMainText", bundle: .module)
    /// `AccentColor` для приложения
    static let swAccent = Color("swAccent", bundle: .module)
    /// Цвет текста в `filled`-кнопке
    static let swFilledButtonText = Color("swFilledButtonText", bundle: .module)
    /// Нажатые `filled`-кнопки
    static let swFilledButtonPressed = Color("swFilledButtonPressed", bundle: .module)
    /// Неактивные кнопки
    static let swDisabledButton = Color("swDisabledButton", bundle: .module)
    /// Цвет текста неактивных кнопок
    static let swDisabledButtonText = Color("swDisabledButtonText", bundle: .module)
    /// `tinted`-кнопки
    static let swTintedButton = Color("swTintedButton", bundle: .module)
    /// Нажатые `tinted`-кнопки
    static let swTintedButtonPressed = Color("swTintedButtonPressed", bundle: .module)
    /// Цвет кнопки удаления фото
    static let swXmarkButton = Color("swXmarkButton", bundle: .module)
    /// Цвет кнопки добавления фото
    static let swAddPhotoButton = Color("swAddPhotoButton", bundle: .module)
    /// Ошибки
    static let swError = Color("swError", bundle: .module)
}

#if DEBUG
struct AllColors_Previews: PreviewProvider {
    static let colors: [Color] = [
        .swBackground, .swCardBackground, .swSmallElements, .swSeparators,
        .swMainText, .swAccent, .swFilledButtonText, .swFilledButtonPressed,
        .swDisabledButton, .swDisabledButtonText,
        .swTintedButton, .swTintedButtonPressed,
        .swXmarkButton, .swAddPhotoButton, .swError
    ]
    static var previews: some View {
        ScrollView {
            VStack(spacing: 4) {
                ForEach(colors, id: \.self) { color in
                    HStack(spacing: 20) {
                        Group {
                            Circle()
                            Circle()
                                .environment(\.colorScheme, .dark)
                        }
                        .foregroundColor(color)
                        .frame(width: 50, height: 50)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
#endif
