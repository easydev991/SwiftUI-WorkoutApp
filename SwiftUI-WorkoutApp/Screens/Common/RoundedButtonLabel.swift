import SwiftUI

/// Лейбл кнопки с модификатором `AdaptiveRoundedRectangleModifier`
struct RoundedButtonLabel: View {
    let title: String
    
    var body: some View {
        Text(title).roundedStyle()
    }
}

struct RoundedButtonLabel_Previews: PreviewProvider {
    static var previews: some View {
        RoundedButtonLabel(title: "Лейбл кнопки")
    }
}
