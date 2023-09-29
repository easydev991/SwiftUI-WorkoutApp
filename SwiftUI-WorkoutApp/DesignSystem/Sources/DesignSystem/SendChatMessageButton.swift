import SwiftUI

public struct SendChatMessageButton: View {
    @Environment(\.isEnabled) private var isEnabled
    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Circle()
                .frame(width: 39, height: 39)
                .foregroundColor(isEnabled ? .swAccent : .swDisabledButton)
                .overlay {
                    Image(systemName: Icons.Regular.arrowUp.rawValue)
                        .foregroundColor(.swBackground)
                }
        }
        .animation(.default, value: isEnabled)
    }
}

#if DEBUG
#Preview {
    SendChatMessageButton {}
}
#endif
