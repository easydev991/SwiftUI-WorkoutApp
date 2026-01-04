import SwiftUI

struct BadgeModifier: ViewModifier {
    let count: Int?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                BadgeView(value: count)
                    .padding(.top, -12)
                    .padding(.trailing, -8)
            }
    }
}

#Preview {
    Button(.edit) {
        print("demo")
    }
    .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
    .swBadge(1)
    .padding()
}
