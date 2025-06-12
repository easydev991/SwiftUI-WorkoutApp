import SwiftUI

struct BadgeView: View {
    let value: Int

    var body: some View {
        Image(systemName: "\(value).circle.fill")
            .foregroundStyle(Color.swAccent)
    }
}

#if DEBUG
#Preview { BadgeView(value: 1) }
#endif
