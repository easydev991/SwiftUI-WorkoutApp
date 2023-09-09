import SwiftUI

struct LoadingOverlayModifier: ViewModifier {
    @State private var isAnimating = false
    private var foreverAnimation: Animation {
        Animation.linear(duration: 2.0)
            .repeatForever(autoreverses: false)
    }

    let isLoading: Bool

    func body(content: Content) -> some View {
        content
            .disabled(isLoading)
            .opacity(isLoading ? 0.5 : 1)
            .overlay {
                Image("LoadingIndicator", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(foreverAnimation, value: isAnimating)
                    .onAppear { isAnimating = true }
                    .opacity(isLoading ? 1 : 0)
            }
            .animation(.default, value: isLoading)
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
