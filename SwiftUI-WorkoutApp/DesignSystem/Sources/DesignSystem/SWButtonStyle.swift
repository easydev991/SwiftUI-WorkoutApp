import SwiftUI

public struct SWButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    private let icon: Icons.Regular?
    private let mode: SWButtonStyle.Mode
    private let size: SWButtonStyle.Size
    private let maxWidth: CGFloat?

    /// Инициализирует `SWButtonStyle`
    /// - Parameters:
    ///   - icon: Иконка
    ///   - mode: Тип кнопки
    ///   - size: Размер кнопки
    ///   - maxWidth: Максимальная ширина, по умолчанию `.infinity`.
    ///   Если задать `nil`, то ширина кнопки будет равна ширине текста и паддингов
    public init(
        icon: Icons.Regular? = nil,
        mode: Mode,
        size: Size,
        maxWidth: CGFloat? = .infinity
    ) {
        self.icon = icon
        self.mode = mode
        self.size = size
        self.maxWidth = maxWidth
    }

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: size.hStackSpacing) {
            leadingIconIfNeeded
            configuration.label
                .lineLimit(1)
                .font(.headline)
        }
        .foregroundColor(foregroundColor)
        .padding(.vertical, size.verticalPadding)
        .padding(.horizontal, size.horizontalPadding)
        .frame(maxWidth: maxWidth)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .foregroundColor(backgroundColor(configuration.isPressed))
        }
        .scaleEffect(configuration.isPressed ? 0.98 : 1)
        .animation(.easeIn(duration: 0.1), value: configuration.isPressed)
        .animation(.default, value: isEnabled)
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

    /// Цвет текста и иконки
    private var foregroundColor: Color {
        guard isEnabled else { return .swDisabledButtonText }
        switch mode {
        case .filled:
            return .swFilledButtonText
        case .tinted:
            return .swAccent
        }
    }

    /// Цвет фона
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
    /// Вид кнопки
    enum Mode: CaseIterable {
        /// Непрозрачная
        case filled
        /// Прозрачная
        case tinted

        /// Описание для превью
        var description: String {
            switch self {
            case .filled: "Filled"
            case .tinted: "Tinted"
            }
        }
    }

    /// Размер кнопки
    enum Size: CaseIterable {
        case large, small

        /// Описание для превью
        var description: String {
            switch self {
            case .large: "Large"
            case .small: "Small"
            }
        }
    }
}

extension SWButtonStyle.Size {
    /// Спейсинг в главном `HStack`
    var hStackSpacing: CGFloat {
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
#Preview {
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
#endif
