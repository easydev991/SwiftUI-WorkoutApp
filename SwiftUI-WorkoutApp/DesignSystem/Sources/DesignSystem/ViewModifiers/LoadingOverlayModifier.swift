import SwiftUI

struct LoadingOverlayModifier: ViewModifier {
    let isLoading: Bool

    func body(content: Content) -> some View {
        ZStack {
            if isLoading {
                content.opacity(0.5)
                LoadingIndicator()
            } else {
                content
            }
        }
        .disabled(isLoading)
        .animation(.default, value: isLoading)
    }
}

private struct LoadingIndicator: View {
    @State private var isAnimating = false

    var body: some View {
        Image("LoadingIndicator", bundle: .module)
            .resizable()
            .frame(width: 50, height: 50)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(
                .linear(duration: 2.0).repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear { isAnimating = true }
    }
}

public extension View {
    /// Добавляет в оверлей индикатор загрузки
    func loadingOverlay(if isLoading: Bool) -> some View {
        modifier(LoadingOverlayModifier(isLoading: isLoading))
    }
}

#if DEBUG
#Preview {
    Text("Loading...").loadingOverlay(if: true)
}
#endif
