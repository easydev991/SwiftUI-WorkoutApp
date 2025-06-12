import SwiftUI

/// Шеврон из дизайн-системы
public struct ChevronView: View {
    public init() {}
    
    public var body: some View {
        Image(systemName: Icons.Regular.chevron.rawValue)
            .resizable()
            .frame(width: 7, height: 12)
            .foregroundStyle(Color.swSmallElements)
    }
}

#if DEBUG
#Preview { ChevronView() }
#endif
