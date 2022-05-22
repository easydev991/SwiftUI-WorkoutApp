import SwiftUI

/// Стиль для основных кнопок на приветственном экране
struct WelcomeButtonTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .foregroundColor(.black)
            .font(.headline)
            .background(Color.white.cornerRadius(8))
    }
}

extension View {
    func welcomeButtonTitle() -> some View {
        modifier(WelcomeButtonTitle())
    }
}
