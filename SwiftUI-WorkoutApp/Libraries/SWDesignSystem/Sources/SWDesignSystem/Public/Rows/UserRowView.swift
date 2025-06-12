import SwiftUI

/// Вьюшка для краткой информации о пользователе
/// или для заявки на добавление в друзья
public struct UserRowView: View {
    @Environment(\.isEnabled) private var isEnabled
    private let baseModel: Mode.BaseModel
    private let actions: Mode.Actions?

    public init(mode: Mode) {
        switch mode {
        case let .regular(baseModel):
            self.baseModel = baseModel
            self.actions = nil
        case let .friendRequest(baseModel, actions):
            self.baseModel = baseModel
            self.actions = actions
        }
    }

    public var body: some View {
        if let actions {
            friendRequestContent(with: actions)
        } else {
            regularContent
                .opacity(isEnabled ? 1 : 0.5)
        }
    }
}

public extension UserRowView {
    enum Mode {
        /// Обычный
        case regular(BaseModel)
        /// Заявка на добавление в друзья
        case friendRequest(BaseModel, Actions)

        /// Модель с данными пользователя
        public struct BaseModel {
            let imageURL: URL?
            let name: String
            let address: String

            public init(
                imageURL: URL?,
                name: String,
                address: String
            ) {
                self.imageURL = imageURL
                self.name = name
                self.address = address
            }
        }

        /// Модель с действиями по заявке
        public struct Actions {
            let accept: () -> Void
            let reject: () -> Void

            public init(
                accept: @escaping () -> Void,
                reject: @escaping () -> Void
            ) {
                self.accept = accept
                self.reject = reject
            }
        }
    }
}

private extension UserRowView {
    var regularContent: some View {
        HStack(alignment: verticalAlignment, spacing: 12) {
            leadingImage
            VStack(alignment: .leading, spacing: 4) {
                userNameView
                addressViewIfAvailable
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .insideCardBackground()
    }

    func friendRequestContent(with actions: Mode.Actions) -> some View {
        HStack(alignment: verticalAlignment, spacing: 12) {
            leadingImage
            VStack(alignment: .leading, spacing: 4) {
                userNameView
                addressViewIfAvailable
                HStack(spacing: 8) {
                    Button(action: actions.accept) {
                        Text("Accept", bundle: .module)
                    }
                    .buttonStyle(SWButtonStyle(mode: .filled, size: .small))
                    Button(action: actions.reject) {
                        Text("Decline", bundle: .module)
                    }
                    .buttonStyle(SWButtonStyle(mode: .tinted, size: .small))
                }
                .padding(.top, 6)
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
    }

    var leadingImage: some View {
        CachedImage(url: baseModel.imageURL, mode: .userListItem)
            .borderedCircleClipShape()
    }

    var userNameView: some View {
        Text(baseModel.name)
            .foregroundStyle(Color.swMainText)
            .font(.headline)
    }

    var verticalAlignment: VerticalAlignment {
        baseModel.address.isEmpty ? .center : .top
    }

    @ViewBuilder
    var addressViewIfAvailable: some View {
        if !baseModel.address.isEmpty {
            Text(baseModel.address)
                .foregroundStyle(Color.swSmallElements)
                .font(.subheadline)
        }
    }
}

#if DEBUG
#Preview {
    let baseModel = UserRowView.Mode.BaseModel(
        imageURL: .init(string: "https://workout.su/uploads/avatars/2019/10/2019-10-07-01-10-08-yow.jpg")!,
        name: "Beautifulbutterfly101",
        address: "Россия, Краснодар"
    )
    return VStack(spacing: 20) {
        UserRowView(mode: .regular(baseModel))
        UserRowView(
            mode: .friendRequest(baseModel, .init(accept: {}, reject: {}))
        )
        .insideCardBackground(padding: 0)
    }
    .padding(.horizontal)
}
#endif
