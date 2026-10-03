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

/// Вращение через `TimelineView`, а не `repeatForever`-анимацию:
/// анимационная транзакция `repeatForever` могла подхватить изменение позиции
/// индикатора и бесконечно «возить» его по экрану во время загрузки
private struct LoadingIndicator: View {
    var body: some View {
        TimelineView(.animation) { context in
            let seconds = context.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: 2.0)
            Image(.loadingIndicator)
                .resizable()
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(seconds / 2.0 * 360))
        }
    }
}

#if DEBUG
#Preview {
    Text("Загрузка...").loadingOverlay(if: true)
}
#endif
