import SwiftUI

struct DividerIfNeededModifier: ViewModifier {
    private let showDivider: Bool
    private let spacing: CGFloat?

    init(_ showDivider: Bool, _ spacing: CGFloat?) {
        self.showDivider = showDivider
        self.spacing = spacing
    }

    func body(content: Content) -> some View {
        VStack(spacing: spacing) {
            content
            SWDivider()
                .opacity(showDivider ? 1 : 0)
        }
    }
}

#if DEBUG
#Preview {
    Text("Hello world")
        .withDivider(if: true, spacing: 16)
}
#endif
