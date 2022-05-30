import SwiftUI

/// Заглушка на случай, когда нет контента
struct EmptyContentView: View {
    @EnvironmentObject private var defaults: DefaultsService
    let message: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text(message)
                .font(.title2)
                .multilineTextAlignment(.center)
            Button(action: action) {
                Text(buttonTitle)
                    .roundedRectangleStyle()
            }
            .opacity(defaults.isAuthorized ? 1 : .zero)
            Spacer()
        }
        .padding()
    }
}

struct EmptyContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyContentView(
            message: "Чатов пока нет",
            buttonTitle: "Открыть список друзей",
            action: {}
        )
        .environmentObject(DefaultsService())
    }
}
