import SwiftUI

public extension Image {
    /// Картинка для вкладки с площадками в таббаре
    static let sportsGroundIcon = Image(.sportsGroundTabbarIcon)
    /// Картинка-заглушка
    static let defaultWorkout = Image(.defaultWorkout)
}

public enum Icons {
    /// Названия системных иконок для таббара
    public enum Tabbar: String, CaseIterable {
        case events = "person.3"
        case messages = "message"
        case profile = "person"
        case settings = "gearshape"
    }

    /// Названия остальных иконок
    public enum Regular: String, CaseIterable {
        case info = "info.circle"
        case plus = "plus.circle"
        case gearshape
        case refresh = "arrow.triangle.2.circlepath"
        case exclamation = "exclamationmark.triangle"
        case exclamationArrowCircle = "exclamationmark.arrow.circlepath"
        case xmarkCircle = "xmark.circle"
        case xmark
        case filterOff = "line.3.horizontal.decrease.circle"
        case filterOn = "line.3.horizontal.decrease.circle.fill"
        case magnifyingglass
        case trash
        case pencil
        case clock
        case personInCircle = "person.circle"
        case location = "location.circle"
        case arrowUp = "arrow.up"
        case message
        case addPerson = "person.crop.circle.badge.plus"
        case deletePerson = "person.crop.circle.badge.minus"
        case signPost = "signpost.right"
        case key = "key.fill"
        case envelope
        case globe = "globe.europe.africa"
        case person = "person.fill"
        case personQuestion = "person.fill.questionmark"
        case calendar
    }

    public enum Misc: String, CaseIterable {
        case chevron = "chevron.forward"

        static var chevronView: some View {
            Image(systemName: Icons.Misc.chevron.rawValue)
                .resizable()
                .frame(width: 7, height: 12)
                .foregroundColor(.swSmallElements)
        }
    }
}

#if DEBUG
#Preview {
    List {
        Section("Tabbar icons") {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Icons.Tabbar.allCases, id: \.rawValue) { icon in
                    HStack(spacing: 16) {
                        Image(systemName: icon.rawValue)
                        Text(icon.rawValue)
                    }
                }
            }
        }
        Section("Regular icons") {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Icons.Regular.allCases, id: \.rawValue) { icon in
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
    }
    .listStyle(.plain)
    .previewDisplayName("Icons")
}
#endif
