import SwiftUI

/// Модификатор, настраивающий фон для карточки
///
/// Карточка - это вьюшка, используемая в форме, или просто контент в рамке
struct CardBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundColor(.swCardBackground)
                    .withShadow()
            }
    }
}

public extension View {
    /// Добавляет фон для карточки
    func insideCardBackground() -> some View {
        modifier(CardBackgroundModifier())
    }
}

#if DEBUG
struct CardBackgroundModifier_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            Text("Light mode text")
                .insideCardBackground()
            Text("Dark mode text")
                .insideCardBackground()
                .environment(\.colorScheme, .dark)
        }
    }
}
#endif
