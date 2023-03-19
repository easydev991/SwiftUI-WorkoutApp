import SwiftUI

struct ShadowIfNeededModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        if colorScheme == .light {
            content
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 4)
        } else {
            content
        }
    }
}

extension View {
    func withShadow() -> some View {
        modifier(ShadowIfNeededModifier())
    }
}
