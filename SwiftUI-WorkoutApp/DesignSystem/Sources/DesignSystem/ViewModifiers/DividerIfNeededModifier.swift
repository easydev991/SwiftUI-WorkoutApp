import SwiftUI

struct DividerIfNeededModifier: ViewModifier {
    private let showDivider: Bool
    private let spacing: CGFloat?

    init(showDivider: Bool, spacing: CGFloat?) {
        self.showDivider = showDivider
        self.spacing = spacing
    }

    func body(content: Content) -> some View {
        VStack(spacing: spacing) {
            content
            Divider()
                .background(Color.swSeparators)
                .opacity(showDivider ? 1 : 0)
        }
    }
}

public extension View {
    /// Добавляет разделитель, если нужно, с указанным спейсингом
    func withDivider(
        if conditionIsMet: Bool,
        spacing: CGFloat = 0
    ) -> some View {
        modifier(
            DividerIfNeededModifier(
                showDivider: conditionIsMet,
                spacing: spacing
            )
        )
    }
}
