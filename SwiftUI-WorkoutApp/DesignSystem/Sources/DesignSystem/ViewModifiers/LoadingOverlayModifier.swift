import SwiftUI

struct LoadingOverlayModifier: ViewModifier {
    @State private var angle: CGFloat = 0
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
                    .opacity(isLoading ? 1 : 0)
                    .rotationEffect(.degrees(isAnimating ? angle : 0))
                    .onChange(of: isLoading) { [isLoading] newValue in
                        switch (isLoading, newValue) {
                        case (false, true):
                            isAnimating = true
                            withAnimation(foreverAnimation) { angle += 360 }
                        default: break
                        }
                    }
            }
            .animation(.default, value: isLoading)
    }
}

public extension View {
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
