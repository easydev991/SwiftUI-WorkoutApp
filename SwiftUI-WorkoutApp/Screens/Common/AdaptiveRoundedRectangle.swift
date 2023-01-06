import SwiftUI

/// Стиль для кнопки
struct AdaptiveRoundedRectangle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color("ButtonTitle"))
            .font(.headline)
            .background(Color("ButtonBackground").cornerRadius(8))
    }
}

extension View {
    func roundedRectangleStyle() -> some View {
        modifier(AdaptiveRoundedRectangle())
    }
}
