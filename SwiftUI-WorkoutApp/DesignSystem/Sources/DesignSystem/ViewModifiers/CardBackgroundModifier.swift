import SwiftUI

/// Модификатор, настраивающий фон для карточки
///
/// Карточка - это вьюшка, используемая в форме, или просто контент в рамке
struct CardBackgroundModifier: ViewModifier {
    let padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundColor(.swCardBackground)
                    .withShadow()
            }
    }
}

public extension View {
    /// Добавляет фон для карточки
    ///
    /// `padding` - отступы вокруг контента, по умолчанию 12
    func insideCardBackground(padding: CGFloat = 12) -> some View {
        modifier(CardBackgroundModifier(padding: padding))
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        Text("Light mode text")
            .insideCardBackground()
        Text("Dark mode text")
            .insideCardBackground()
            .environment(\.colorScheme, .dark)
    }
}
#endif
