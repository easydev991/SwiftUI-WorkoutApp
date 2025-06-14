import SwiftUI

/// Вьюшка для записи в дневнике
public struct JournalRowView: View {
    private let model: Model

    public init(model: Model) {
        self.model = model
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                leadingImage
                VStack(alignment: .leading, spacing: 4) {
                    titleView
                    dateTextView
                }
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                menuButtonIfNeeded
            }
            bodyTextView
        }
        .insideCardBackground()
    }
}

public extension JournalRowView {
    struct Model {
        let avatarURL: URL?
        let title: String
        let dateText: String
        let bodyText: String
        let bodyTextLinelimit: Int?
        let menuOptions: [GenericButtonModel]

        /// Инициализирует `JournalRowView.Model`
        /// - Parameters:
        ///   - avatarURL: `URL` картинки
        ///   - title: Заголовок
        ///   - dateText: Текст с датой записи
        ///   - bodyText: Запись в дневнике
        ///   - bodyTextLinelimit: Лимит строк в записи, по дефолту без лимита
        ///   - menuOptions: Кнопки для меню справа
        public init(
            avatarURL: URL?,
            title: String,
            dateText: String,
            bodyText: String,
            bodyTextLinelimit: Int? = nil,
            menuOptions: [GenericButtonModel] = []
        ) {
            self.avatarURL = avatarURL
            self.title = title
            self.dateText = dateText
            self.bodyText = bodyText
            self.bodyTextLinelimit = bodyTextLinelimit
            self.menuOptions = menuOptions
        }

        public struct GenericButtonModel: Identifiable {
            public var id: String { option.id }
            let option: Option
            let action: () -> Void

            public init(_ option: Option, action: @escaping () -> Void) {
                self.option = option
                self.action = action
            }

            public enum Option: Identifiable {
                public var id: String { systemImageName }
                case edit, setup, report, delete
                var title: LocalizedStringKey {
                    switch self {
                    case .edit: "Edit"
                    case .setup: "Configure"
                    case .report: "Report"
                    case .delete: "Delete"
                    }
                }

                var systemImageName: String {
                    switch self {
                    case .edit: "pencil"
                    case .setup: "gearshape"
                    case .report: "exclamationmark.triangle"
                    case .delete: "trash"
                    }
                }

                var buttonRole: ButtonRole? {
                    switch self {
                    case .report, .delete: .destructive
                    default: nil
                    }
                }
            }
        }
    }
}

private extension JournalRowView {
    var leadingImage: some View {
        CachedImage(url: model.avatarURL, mode: .journalAvatar)
    }

    var titleView: some View {
        Text(model.title)
            .foregroundStyle(Color.swMainText)
            .font(.headline)
    }

    var dateTextView: some View {
        Text(model.dateText)
            .foregroundStyle(Color.swSmallElements)
            .font(.footnote.weight(.medium))
    }

    var bodyTextView: some View {
        Text(.init(model.bodyText))
            .font(.subheadline)
            .foregroundStyle(Color.swMainText)
            .tint(.swAccent)
            .textSelection(.enabled)
            .multilineTextAlignment(.leading)
            .lineLimit(model.bodyTextLinelimit)
    }

    @ViewBuilder
    var menuButtonIfNeeded: some View {
        if !model.menuOptions.isEmpty {
            Menu {
                ForEach(model.menuOptions) { model in
                    Button(role: model.option.buttonRole, action: model.action) {
                        Label {
                            Text(model.option.title, bundle: .module)
                        } icon: {
                            Image(systemName: model.option.systemImageName)
                        }
                    }
                }
            } label: {
                Image(systemName: Icons.Regular.ellipsis.rawValue)
                    .frame(width: 30, height: 30, alignment: .topTrailing)
                    .foregroundStyle(Color.swSmallElements)
            }
            .onTapGesture { hapticFeedback(.rigid) }
        }
    }
}

#if DEBUG
#Preview {
    JournalRowView(
        model: .init(
            avatarURL: .init(string: "https://workout.su/uploads/avatars/2019/10/2019-10-07-01-10-08-yow.jpg")!,
            title: "Дневник 1",
            dateText: "21 мая 2023",
            bodyText: "Классная площадка, часто тренируюсь здесь с друзьями. Сегодня тренировался на стадионе. Для начала небольшая пробежка для разминки",
            bodyTextLinelimit: 2
        )
    )
    .padding(.horizontal)
}
#endif
