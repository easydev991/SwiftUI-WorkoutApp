import SwiftUI

public struct SWDivider: View {
    public init() {}

    public var body: some View {
        Divider().background(Color.swSeparators)
    }
}

#if DEBUG
#Preview { SWDivider() }
#endif
