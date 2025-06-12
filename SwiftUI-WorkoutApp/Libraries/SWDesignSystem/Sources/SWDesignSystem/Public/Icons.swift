import SwiftUI

public extension Image {
    /// Картинка для вкладки с площадками в таббаре
    static let parkTabIcon = Image(.parkTabbarIcon)
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
        
        public var view: some View { Image(systemName: rawValue) }
        public var imageView: Image { Image(systemName: rawValue) }
    }

    /// Названия остальных иконок
    public enum Regular: String, CaseIterable {
        case ellipsis
        case plus
        case eye
        case checkmark
        case share = "square.and.arrow.up"
        case noSignal = "wifi.slash"
        case gearshape
        case refresh = "arrow.triangle.2.circlepath"
        case exclamation = "exclamationmark.triangle"
        case exclamationArrowCircle = "exclamationmark.arrow.circlepath"
        case xmark = "xmark"
        case filter = "line.3.horizontal.decrease.circle"
        case magnifyingglass
        case trash
        case pencil
        case clock
        case person = "person"
        case location = "location"
        case arrowUp = "arrow.up"
        case message
        case addPerson = "person.crop.circle.badge.plus"
        case deletePerson = "person.crop.circle.badge.minus"
        case signPost = "signpost.right"
        case key = "key.fill"
        case globe = "globe.europe.africa"
        case personQuestion = "person.fill.questionmark"
        case calendar
        case chevron = "chevron.forward"
        
        public var view: some View { Image(systemName: rawValue) }
        public var imageView: Image { Image(systemName: rawValue) }
    }
}

#if DEBUG
#Preview {
    List {
        Section("Tabbar icons") {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Icons.Tabbar.allCases, id: \.rawValue) { icon in
                    HStack(spacing: 16) {
                        icon.view
                        Text(icon.rawValue)
                    }
                }
            }
        }
        Section("Regular icons") {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Icons.Regular.allCases, id: \.rawValue) { icon in
                    HStack(spacing: 16) {
                        icon.view
                        Text(icon.rawValue)
                    }
                }
            }
        }
    }
}
#endif
