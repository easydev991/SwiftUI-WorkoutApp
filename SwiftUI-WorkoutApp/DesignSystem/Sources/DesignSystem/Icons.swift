import SwiftUI

public extension Image {
    /// Картинка для вкладки с площадками в таббаре
    static let sportsGroundIcon = Image("SportsGroundTabbarIcon", bundle: .module)
    /// Картинка-заглушка
    static let defaultWorkoutImage = Image("defaultWorkoutImage", bundle: .module)
}

public enum Icons {
    /// Названия системных иконок для таббара
    public enum Tabbar: String {
        case events = "person.3"
        case messages = "message"
        case journals = "list.bullet.circle"
        case profile = "person"
    }

    /// Названия системных иконок, используемых внутри кнопок со стилем `SWButtonStyle`
    public enum SWButton: String, CaseIterable {
        case message
        case addPerson = "person.crop.circle.badge.plus"
        case deletePerson = "person.crop.circle.badge.minus"
        case pencil
    }

    /// Названия системных иконок, используемых внутри обычных кнопок
    public enum Button: String, CaseIterable {
        case info = "info.circle"
        case plus = "plus.circle"
        case gearshape
        case refresh = "arrow.triangle.2.circlepath"
        case exclamation = "exclamationmark.triangle"
        case xmark = "xmark.circle"
        case filter = "line.3.horizontal.decrease.circle"
        case magnifyingglass
    }

    public enum Misc: String, CaseIterable {
        case clock
        case personInCircle = "person.circle"
        case location = "location.circle"
        case arrowUp = "arrow.up"
        case chevron = "chevron.forward"

        static var chevronView: some View {
            Image(systemName: Icons.Misc.chevron.rawValue)
                .resizable()
                .frame(width: 7, height: 12)
                .foregroundColor(.swSmallElements)
        }
    }

    /// Иконки для `ListRow`
    public enum ListRow: String, CaseIterable {
        case signPost = "signpost.right"
        case envelope
        case globe = "globe.europe.africa"
        case person = "person.fill"
        case personQuestion = "person.fill.questionmark"
        case calendar
    }
}

#if DEBUG
struct ButtonIcons_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section("SWButton icons") {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Icons.SWButton.allCases, id: \.rawValue) { icon in
                        HStack(spacing: 16) {
                            Image(systemName: icon.rawValue)
                            Text(icon.rawValue)
                        }
                    }
                }
            }
            Section("Button icons") {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Icons.Button.allCases, id: \.rawValue) { icon in
                        HStack(spacing: 16) {
                            Image(systemName: icon.rawValue)
                            Text(icon.rawValue)
                        }
                    }
                }
            }
            Section("Misc icons") {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Icons.Misc.allCases, id: \.rawValue) { icon in
                        HStack(spacing: 16) {
                            Image(systemName: icon.rawValue)
                            Text(icon.rawValue)
                        }
                    }
                }
            }
            Section("ListRow icons") {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Icons.ListRow.allCases, id: \.rawValue) { icon in
                        HStack(spacing: 16) {
                            Image(systemName: icon.rawValue)
                            Text(icon.rawValue)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .previewDisplayName("Icons")
    }
}
#endif
