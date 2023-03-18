import SwiftUI

public struct SWButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    private let icon: Icons.SWButton?
    private let mode: Mode

    public init(icon: Icons.SWButton? = nil, mode: SWButtonStyle.Mode) {
        self.icon = icon
        self.mode = mode
    }

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 10) {
            leadingIconIfNeeded
            configuration.label
                .lineLimit(1)
                .font(.headline)
        }
        .foregroundColor(foregroundColor)
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
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
                .frame(width: 19)
        }
    }

    private var foregroundColor: Color {
        guard isEnabled else { return .gray3 }
        switch mode {
        case .filled:
            return .black2
        case .tinted:
            return .swGreen
        }
    }

    private func backgroundColor(_ isPressed: Bool) -> Color {
        guard isEnabled else { return .green3 }
        switch mode {
        case .filled:
            return isPressed ? .green2 : .swGreen
        case .tinted:
            #warning("Обновить по фигме")
            return .green4
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
}

#if DEBUG
struct SWButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section("Текст без иконки") {
                ForEach(SWButtonStyle.Mode.allCases, id: \.self) { mode in
                    Button(mode.description + ", only text (enabled)") {}
                        .buttonStyle(SWButtonStyle(mode: mode))
                    Button(mode.description + ", only text (disabled)") {}
                        .buttonStyle(SWButtonStyle(mode: mode))
                        .disabled(true)
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            Section("Иконка с текстом") {
                ForEach(SWButtonStyle.Mode.allCases, id: \.self) { mode in
                    Button(mode.description + ", icon with text (enabled)") {}
                        .buttonStyle(SWButtonStyle(icon: .message, mode: mode))
                    Button(mode.description + ", icon with text (disabled)") {}
                        .buttonStyle(SWButtonStyle(icon: .message, mode: mode))
                        .disabled(true)
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
