import SwiftUI

public enum Icons {
    /// Иконки, используемые внутри кнопок со стилем `SWButtonStyle`
    public enum SWButton: String, CaseIterable {
        case message
        case addPerson = "person.crop.circle.badge.plus"
        case deletePerson = "person.crop.circle.badge.minus"
    }

    /// Иконки, используемые внутри обычных кнопок
    public enum Button: String, CaseIterable {
        case info = "info.circle"
        case plus = "plus.circle"
        case gearshape
        case refresh = "arrow.triangle.2.circlepath"
        case exclamation = "exclamationmark.circle"
        case xmark = "xmark.circle"
        case filter = "line.3.horizontal.decrease.circle"
        case magnifyingglass
    }
}

#if DEBUG
struct ButtonIcons_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section("SWButton icons") {
                VStack(spacing: 16) {
                    ForEach(Icons.SWButton.allCases, id: \.rawValue) { icon in
                        Image(systemName: icon.rawValue)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            Section("Button icons") {
                VStack(spacing: 16) {
                    ForEach(Icons.Button.allCases, id: \.rawValue) { icon in
                        Image(systemName: icon.rawValue)
                            .foregroundColor(.swGreen)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .listStyle(.plain)
        .previewDisplayName("Icons")
    }
}
#endif
