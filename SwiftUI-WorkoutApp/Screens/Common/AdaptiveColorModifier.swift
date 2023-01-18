import SwiftUI

/// Модификатор для `foreground`/`background` цвета
///
/// Цвет меняется с черного на белый в зависимости от `@Environment(\.colorScheme)`
struct AdaptiveColorModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var cornerRadius: CGFloat = 8
    let mode: Mode

    func body(content: Content) -> some View {
        switch mode {
        case .background:
            content.background(color.cornerRadius(cornerRadius))
        case .foreground:
            content.foregroundColor(color)
        }
    }
}

extension AdaptiveColorModifier {
    enum Mode {
        /// `inverse`: `true` - цвет противоположный цветовой схеме, `false` - цвет совпадает с цветовой схемой
        case foreground(inverse: Bool = true)
        case background
    }
}

private extension AdaptiveColorModifier {
    var color: Color {
        switch mode {
        case let .foreground(inverse):
            if inverse {
                return colorScheme == .light ? .white : .black
            } else {
                return colorScheme == .light ? .black : .white
            }
        case .background:
            return colorScheme == .light ? .black : .white
        }
    }
}

extension View {
    func adaptiveColor(
        radius: CGFloat = 8,
        _ mode: AdaptiveColorModifier.Mode
    ) -> some View {
        modifier(AdaptiveColorModifier(cornerRadius: radius, mode: mode))
    }
}
