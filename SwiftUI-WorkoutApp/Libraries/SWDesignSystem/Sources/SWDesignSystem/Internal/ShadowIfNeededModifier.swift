import SwiftUI

/// Модификатор, добавляющий тень в светлой теме
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

#if DEBUG
#Preview {
    Text("Hello world")
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.swCardBackground)
                .frame(height: 50)
                .withShadow()
        }
}
#endif
