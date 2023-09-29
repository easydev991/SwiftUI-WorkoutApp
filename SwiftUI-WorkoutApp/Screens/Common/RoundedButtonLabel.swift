import SwiftUI

/// Лейбл кнопки с модификатором `AdaptiveRoundedRectangleModifier`
struct RoundedButtonLabel: View {
    let title: String

    var body: some View {
        Text(title).roundedStyle()
    }
}

#if DEBUG
#Preview {
    RoundedButtonLabel(title: "Лейбл кнопки")
}
#endif
