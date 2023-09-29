import SwiftUI

struct LoadingOverlayModifier: ViewModifier {
    let isLoading: Bool

    func body(content: Content) -> some View {
        content
            .disabled(isLoading)
            .opacity(isLoading ? 0.5 : 1)
            .animation(.default, value: isLoading)
            .overlay {
                LoadingIndicator(isVisible: isLoading)
            }
    }
}

private struct LoadingIndicator: View {
    @State private var isAnimating = false
    let isVisible: Bool

    var body: some View {
        Image("LoadingIndicator", bundle: .module)
            .resizable()
            .frame(width: 50, height: 50)
            .opacity(isVisible ? 1 : 0)
            .animation(.default, value: isVisible)
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
struct LoadingOverlayModifier_Previews: PreviewProvider {
    static var previews: some View {
        Text("Loading...")
            .loadingOverlay(if: true)
    }
}
#endif
