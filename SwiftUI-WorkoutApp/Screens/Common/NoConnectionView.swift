import SWDesignSystem
import SwiftUI

struct NoConnectionView: View {
    var body: some View {
        VStack(spacing: 16) {
            Icons.Regular.noSignal.imageView
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundStyle(.accent)
            Text("Нет соединения с сетью")
                .foregroundStyle(Color.swMainText)
                .multilineTextAlignment(.center)
                .padding(.bottom, 6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
#Preview {
    NoConnectionView()
}
#endif
