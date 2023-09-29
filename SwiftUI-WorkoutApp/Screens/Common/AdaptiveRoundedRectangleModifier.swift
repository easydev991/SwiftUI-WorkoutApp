import SwiftUI

/// Стиль для лейбла черно-белой кнопки в зависимости от цветовой темы
///
/// - `height`: `48`
/// - `maxWidth`: `.infinity`
/// - `font`: `.headline`
struct AdaptiveRoundedRectangleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .adaptiveColor(.foreground())
            .font(.headline)
            .adaptiveColor(.background)
    }
}

extension View {
    func roundedStyle() -> some View {
        modifier(AdaptiveRoundedRectangleModifier())
    }
}

#if DEBUG
#Preview {
    Text("Какой-то текст")
        .roundedStyle()
        .padding()
}
#endif
