import SwiftUI

public struct SWButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    private let mode: Mode
    private let icon: Icons.SWButton?

    public init(mode: SWButtonStyle.Mode, icon: Icons.SWButton? = nil) {
        self.mode = mode
        self.icon = icon
    }

    public func makeBody(configuration: Configuration) -> some View {
        contentStack(configuration)
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
    private func contentStack(_ configuration: Configuration) -> some View {
        switch mode {
        case let .filled(content):
            switch content {
            case let .onlyIcon(icon):
                Image(systemName: icon.rawValue)
            case let .iconWithText(icon):
                HStack(spacing: 10) {
                    Image(systemName: icon.rawValue)
                    configuration.label
                        .lineLimit(1)
                        .font(.headline)
                }
            case .onlyText:
                configuration.label
                    .lineLimit(1)
                    .font(.headline)
            }
        case let .tinted(content):
            switch content {
            case let .onlyIcon(icon):
                Image(systemName: icon.rawValue)
            case let .iconWithText(icon):
                HStack(spacing: 10) {
                    Image(systemName: icon.rawValue)
                    configuration.label
                        .lineLimit(1)
                        .font(.headline)
                }
            case .onlyText:
                configuration.label
                    .lineLimit(1)
                    .font(.headline)
            }
        }
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
    enum Mode {
        case filled(_ label: LabelContent)
        case tinted(_ label: LabelContent)

        var description: String {
            switch self {
            case .filled: return "Filled"
            case .tinted: return "Tinted"
            }
        }

        public enum LabelContent {
            case onlyIcon(Icons.SWButton)
            case onlyText
            case iconWithText(Icons.SWButton)
        }
    }
}

#if DEBUG
struct SWButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section("Текст без иконки") {
                Button("Filled, only text (enabled)") {}
                    .buttonStyle(SWButtonStyle(mode: .filled(.onlyText)))
                Button("Filled, only text (disabled)") {}
                    .buttonStyle(SWButtonStyle(mode: .filled(.onlyText)))
                    .disabled(true)
                Button("Tinted, only text (enabled)") {}
                    .buttonStyle(SWButtonStyle(mode: .tinted(.onlyText)))
                Button("Tinted, only text (disabled)") {}
                    .buttonStyle(SWButtonStyle(mode: .tinted(.onlyText)))
                    .disabled(true)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            Section("Иконка с текстом") {
                Button("Filled, icon with text (enabled)") {}
                    .buttonStyle(SWButtonStyle(mode: .filled(.iconWithText(.message))))
                Button("Filled, icon with text (disabled)") {}
                    .buttonStyle(SWButtonStyle(mode: .filled(.iconWithText(.message))))
                    .disabled(true)
                Button("Tinted, icon with text (enabled)") {}
                    .buttonStyle(SWButtonStyle(mode: .tinted(.iconWithText(.message))))
                Button("Tinted, icon with text (disabled)") {}
                    .buttonStyle(SWButtonStyle(mode: .tinted(.iconWithText(.message))))
                    .disabled(true)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            Section("Иконка без текста") {
                Button("Filled, only icon (enabled)") {}
                    .buttonStyle(SWButtonStyle(mode: .filled(.onlyIcon(.message))))
                Button("Filled, only icon (disabled)") {}
                    .buttonStyle(SWButtonStyle(mode: .filled(.onlyIcon(.message))))
                    .disabled(true)
                Button("Tinted, only icon (enabled)") {}
                    .buttonStyle(SWButtonStyle(mode: .tinted(.onlyIcon(.message))))
                Button("Tinted, only icon (disabled)") {}
                    .buttonStyle(SWButtonStyle(mode: .tinted(.onlyIcon(.message))))
                    .disabled(true)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.grouped)
        .previewDisplayName("SWButtonStyle")
    }
}
#endif
