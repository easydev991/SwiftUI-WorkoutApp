import SwiftUI

public struct SWDivider: View {
    public init() {}

    public var body: some View {
        Divider().background(Color.swSeparators)
    }
}

#if DEBUG
struct SWDivider_Previews: PreviewProvider {
    static var previews: some View {
        SWDivider()
    }
}
#endif
