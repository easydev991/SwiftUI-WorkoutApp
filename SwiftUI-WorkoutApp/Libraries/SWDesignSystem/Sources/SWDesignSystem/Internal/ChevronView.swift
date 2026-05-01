import SwiftUI

/// Шеврон из дизайн-системы
struct ChevronView: View {
    init() {}

    var body: some View {
        Image(systemName: Icons.Regular.chevron.rawValue)
            .resizable()
            .frame(width: 7, height: 12)
            .foregroundStyle(Color.swSmallElements)
    }
}

#if DEBUG
#Preview { ChevronView() }
#endif
