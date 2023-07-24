import SwiftUI

/// В фигме называется "Ячейка формы"
public struct FormRowView: View {
    public var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

public extension FormRowView {
    /// Контент слева
    enum LeadingContent {
        public struct TitleSubtitle {
            let title, subtitle: String
            let subtitleColor: Color

            init(
                title: String,
                subtitle: String,
                subtitleColor: Color = .swSmallElements
            ) {
                self.title = title
                self.subtitle = subtitle
                self.subtitleColor = subtitleColor
            }
        }

        /// Текст
        case text(String)
        /// Заголовок и подзаголовок
        case titleSubtitle(TitleSubtitle)
    }
}

#if DEBUG
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        FormRowView()
    }
}
#endif
