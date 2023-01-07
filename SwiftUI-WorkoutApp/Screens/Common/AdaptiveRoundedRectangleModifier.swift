import SwiftUI

/// Стиль для лейбла черно-белой кнопки в зависимости от цветовой темы
///
/// - `maxWidth`: `.infinity`
/// - `font`: `.headline`
struct AdaptiveRoundedRectangleModifier: ViewModifier {
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
    func roundedStyle() -> some View {
        modifier(AdaptiveRoundedRectangleModifier())
    }
}

#if DEBUG
struct AdaptiveRoundedRectangleModifier_Previews: PreviewProvider {
    static var previews: some View {
        Text("Какой-то текст")
            .roundedStyle()
    }
}
#endif
