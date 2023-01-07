import SwiftUI

/// Стиль для кнопок неавторизованного пользователя
///
/// - Регистрация
/// - Авторизация
struct IncognitoButtonLabelModifier: ViewModifier {
    let source: Source

    func body(content: Content) -> some View {
        switch source {
        case .welcomeView:
            content
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .foregroundColor(.black)
                .font(.headline)
                .background(Color.white.cornerRadius(8))
        case .incognitoView:
            content
                .roundedStyle()
        }
    }
}

extension IncognitoButtonLabelModifier {
    enum Source: CaseIterable {
        case welcomeView, incognitoView
    }
}

extension View {
    func incognitoButtonStyle(source: IncognitoButtonLabelModifier.Source) -> some View {
        modifier(IncognitoButtonLabelModifier(source: source))
    }
}
