import SwiftUI

public extension View {
    /// Придает вьюшке форму `circle` с бордюром цвета `swAccent`
    func borderedCircleClipShape() -> some View {
        modifier(BorderedClipShapeModifier(clipShape: .circle))
    }
    
    /// Придает вьюшке форму `roundedRectangle` с бордюром цвета `swAccent`
    func borderedRoundedRectClipShape() -> some View {
        modifier(BorderedClipShapeModifier(clipShape: .roundedRect))
    }
    
    /// Добавляет фон для карточки
    ///
    /// `padding` - отступы вокруг контента, по умолчанию 12
    func insideCardBackground(padding: CGFloat = 12) -> some View {
        modifier(CardBackgroundModifier(padding: padding))
    }
    
    /// Добавляет разделитель, если нужно, с указанным спейсингом
    func withDivider(if showDivider: Bool, spacing: CGFloat = 0) -> some View {
        modifier(DividerIfNeededModifier(showDivider, spacing))
    }
    
    /// Добавляет в оверлей индикатор загрузки
    func loadingOverlay(if isLoading: Bool) -> some View {
        modifier(LoadingOverlayModifier(isLoading: isLoading))
    }
    
    /// Добавляет тень в светлой теме
    func withShadow() -> some View {
        modifier(ShadowIfNeededModifier())
    }
    
    /// Вызывает habtic feedback
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
