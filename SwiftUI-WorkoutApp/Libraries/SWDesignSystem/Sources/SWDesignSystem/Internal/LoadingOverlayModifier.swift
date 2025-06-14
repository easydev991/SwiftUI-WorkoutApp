import SwiftUI

struct LoadingOverlayModifier: ViewModifier {
    let isLoading: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
                .environment(\.isLoading, isLoading)
                .opacity(isLoading ? 0.5 : 1)
                .disabled(isLoading)
            if isLoading {
                LoadingIndicator()
            }
        }
        .animation(.default, value: isLoading)
    }
}

private struct LoadingIndicator: View {
    @State private var isAnimating = false

    var body: some View {
        Image(.loadingIndicator)
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

#if DEBUG
#Preview {
    Text("Загрузка...").loadingOverlay(if: true)
}
#endif
