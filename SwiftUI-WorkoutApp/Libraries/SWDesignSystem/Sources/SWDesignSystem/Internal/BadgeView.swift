import SwiftUI

struct BadgeView: View {
    let value: Int?

    var body: some View {
        if let value, value > 0 {
            Text(value > 99 ? "99+" : "\(value)")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .padding(6)
                .background(.red)
                .clipShape(.circle)
        }
    }
}

#if DEBUG
#Preview { BadgeView(value: 1) }
#endif
