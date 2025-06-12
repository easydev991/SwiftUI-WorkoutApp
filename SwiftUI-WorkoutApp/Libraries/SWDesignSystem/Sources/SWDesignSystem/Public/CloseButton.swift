import SwiftUI

/// Кнопка "Закрыть"
public struct CloseButton: View {
    private let mode: Mode
    private let action: () -> Void
    
    public init(mode: Mode, action: @escaping () -> Void) {
        self.mode = mode
        self.action = action
    }
    
    public var body: some View {
        contentView
            .foregroundStyle(Color.swAccent)
            .accessibilityIdentifier("closeButton")
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch mode {
        case .text:
            Button(action: action) {
                Text("Close", bundle: .module)
            }
        case .xmark:
            Button(action: action) {
                Image(systemName: Icons.Regular.xmark.rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
                    .symbolVariant(.circle)
            }
        }
    }
}

public extension CloseButton {
    enum Mode {
        /// Иконка "xmark.circle"
        case xmark
        /// Текст "Закрыть"
        case text
    }
}

#Preview {
    VStack(spacing: 20) {
        CloseButton(mode: .text, action: {})
        CloseButton(mode: .xmark, action: {})
    }
}
