import SwiftUI

struct SWButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    let mode: Mode

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(tintColor)
            .font(.headline)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundColor(backgroundColor(isPressed: configuration.isPressed))
            }
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.easeIn(duration: 0.1), value: configuration.isPressed)
    }
}

extension SWButtonStyle {
    enum Mode: CaseIterable, Identifiable {
        var id: Self { self }

        case filled, tinted

        var descriptin: String {
            switch self {
            case .filled: return "Filled"
            case .tinted: return "Tinted"
            }
        }
    }

    var tintColor: Color {
        guard isEnabled else { return .gray3 }
        return mode == .filled ? .black2 : .swGreen
    }

    func backgroundColor(isPressed: Bool) -> Color {
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

#if DEBUG
struct SWButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            ForEach(SWButtonStyle.Mode.allCases) { mode in
                Button(mode.descriptin + " (enabled)", action: {})
                    .buttonStyle(SWButtonStyle(mode: mode))
                Button(mode.descriptin + " (disabled)", action: {})
                    .buttonStyle(SWButtonStyle(mode: mode))
                    .disabled(true)
            }
            .padding(.horizontal)
        }
        .padding()
        .previewDisplayName("SWButtonStyle")
        .previewLayout(.sizeThatFits)
    }
}
#endif
