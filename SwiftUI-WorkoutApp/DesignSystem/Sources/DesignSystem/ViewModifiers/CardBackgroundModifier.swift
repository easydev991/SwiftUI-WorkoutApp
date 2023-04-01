import SwiftUI

struct CardBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundColor(.swCardBackground)
                    .withShadow()
            }
    }
}

extension View {
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
