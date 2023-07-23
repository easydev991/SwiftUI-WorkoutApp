import SwiftUI

public struct SWDivider: View {
    private let ignoreDefaultHorizontalPadding: Bool
    
    public init(ignoreDefaultHorizontalPadding: Bool = false) {
        self.ignoreDefaultHorizontalPadding = ignoreDefaultHorizontalPadding
    }
    
    public var body: some View {
        Divider()
            .background(Color.swSeparators)
            .padding(.horizontal, ignoreDefaultHorizontalPadding ? -16 : 0)
    }
}

#if DEBUG
struct SWDivider_Previews: PreviewProvider {
    static var previews: some View {
        SWDivider()
    }
}
#endif
