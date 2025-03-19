import SWDesignSystem
import SwiftUI
import SWModels

struct CommonErrorView: View {
    let errorKind: ErrorKind

    var body: some View {
        ContainerRelativeView {
            if case let .common(message) = errorKind {
                VStack(spacing: 16) {
                    Text("Ошибка").bold()
                    Text(.init(message))
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(Color.swMainText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                NoConnectionView()
            }
        }
    }
}

#if DEBUG
#Preview("Общая ошибка") {
    CommonErrorView(errorKind: .common(message: "Неизвестная ошибка"))
}

#Preview("Нет подключения") {
    CommonErrorView(errorKind: .notConnected)
}
#endif
