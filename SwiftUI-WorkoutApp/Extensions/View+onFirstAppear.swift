import SwiftUI

private struct OnFirstAppear: ViewModifier {
    @State private var hasAppeared = false
    let action: () -> Void

    func body(content: Content) -> some View {
        content.onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            action()
        }
    }
}

extension View {
    /// Выполняет действие только при первом появлении view
    func onFirstAppear(_ action: @escaping () -> Void) -> some View {
        modifier(OnFirstAppear(action: action))
    }
}
