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
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.swCardBackground)
                    .withShadow()
            }
    }
}

#if DEBUG
#Preview {
    Text("Текст для превью")
        .insideCardBackground()
}
#endif
