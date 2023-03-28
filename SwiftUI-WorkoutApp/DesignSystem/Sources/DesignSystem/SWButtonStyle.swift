import SwiftUI

public struct SWButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    private let icon: Icons.SWButton?
    private let mode: SWButtonStyle.Mode
    private let size: SWButtonStyle.Size

    public init(
        icon: Icons.SWButton? = nil,
        mode: SWButtonStyle.Mode,
        size: SWButtonStyle.Size
    ) {
        self.icon = icon
        self.mode = mode
        self.size = size
    }

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: size.hstackSpacing) {
            leadingIconIfNeeded
            configuration.label
                .lineLimit(1)
                .font(.headline)
        }
        .foregroundColor(foregroundColor)
        .padding(.vertical, size.verticalPadding)
        .padding(.horizontal, size.horizontalPadding)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .foregroundColor(backgroundColor(configuration.isPressed))
        }
        .scaleEffect(configuration.isPressed ? 0.98 : 1)
        .animation(.easeIn(duration: 0.1), value: configuration.isPressed)
    }

    @ViewBuilder
    private var leadingIconIfNeeded: some View {
        if let icon {
            Image(systemName: icon.rawValue)
                .resizable()
                .scaledToFit()
                .frame(width: size.iconWidth)
        }
    }

    private var foregroundColor: Color {
        guard isEnabled else { return .swDisabledButtonText }
        switch mode {
        case .filled:
            return .swFilledButtonText
        case .tinted:
            return .swAccent
        }
    }

    private func backgroundColor(_ isPressed: Bool) -> Color {
        guard isEnabled else { return .swDisabledButton }
        switch mode {
        case .filled:
            return isPressed ? .swFilledButtonPressed : .swAccent
        case .tinted:
            return isPressed ? .swTintedButtonPressed : .swTintedButton
        }
    }
}

public extension SWButtonStyle {
    enum Mode: CaseIterable {
        case filled, tinted

        var description: String {
            switch self {
            case .filled: return "Filled"
            case .tinted: return "Tinted"
            }
        }
    }

    enum Size: CaseIterable {
        case large, small

        var description: String {
            switch self {
            case .large: return "Large"
            case .small: return "Small"
            }
        }
    }
}

extension SWButtonStyle.Size {
    var hstackSpacing: CGFloat {
        self == .large ? 10 : 6
    }

    var verticalPadding: CGFloat {
        self == .large ? 12 : 8
    }

    var horizontalPadding: CGFloat {
        self == .large ? 20 : 16
    }

    var iconWidth: CGFloat {
        self == .large ? 19 : 15
    }
}

#if DEBUG
struct SWButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section("Large") {
                Section("Текст без иконки") {
                    ForEach(SWButtonStyle.Mode.allCases, id: \.self) { mode in
                        Button(mode.description + ", only text (enabled)") {}
                            .buttonStyle(SWButtonStyle(mode: mode, size: .large))
                        Button(mode.description + ", only text (disabled)") {}
                            .buttonStyle(SWButtonStyle(mode: mode, size: .large))
                            .disabled(true)
                    }
                }
                Section("Иконка с текстом") {
                    ForEach(SWButtonStyle.Mode.allCases, id: \.self) { mode in
                        Button(mode.description + ", icon with text (enabled)") {}
                            .buttonStyle(SWButtonStyle(icon: .message, mode: mode, size: .large))
                        Button(mode.description + ", icon with text (disabled)") {}
                            .buttonStyle(SWButtonStyle(icon: .message, mode: mode, size: .large))
                            .disabled(true)
                    }
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            Section("Small") {
                Section("Текст без иконки") {
                    ForEach(SWButtonStyle.Mode.allCases, id: \.self) { mode in
                        Button(mode.description + ", only text (enabled)") {}
                            .buttonStyle(SWButtonStyle(mode: mode, size: .small))
                        Button(mode.description + ", only text (disabled)") {}
                            .buttonStyle(SWButtonStyle(mode: mode, size: .small))
                            .disabled(true)
                    }
                }
                Section("Иконка с текстом") {
                    ForEach(SWButtonStyle.Mode.allCases, id: \.self) { mode in
                        Button(mode.description + ", icon with text (enabled)") {}
                            .buttonStyle(SWButtonStyle(icon: .message, mode: mode, size: .small))
                        Button(mode.description + ", icon with text (disabled)") {}
                            .buttonStyle(SWButtonStyle(icon: .message, mode: mode, size: .small))
                            .disabled(true)
                    }
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.grouped)
        .previewDisplayName("SWButtonStyle")
    }
}
#endif
