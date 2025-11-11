import SwiftUI

/// Кнопка с площадкой для использования в списках
public struct ParkRowItemView: View {
    private let imageURL: URL?
    private let title: String
    private let address: String?
    private let usersTrainHereText: String
    private let action: () -> Void

    public init(
        imageURL: URL?,
        title: String,
        address: String?,
        usersTrainHereText: String,
        action: @escaping () -> Void
    ) {
        self.imageURL = imageURL
        self.title = title
        self.address = address
        self.usersTrainHereText = usersTrainHereText
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ParkRowView(
                imageURL: imageURL,
                title: title,
                address: address,
                usersTrainHereText: usersTrainHereText
            )
        }
        .listRowBackground(Color.clear)
        .listRowInsets(
            .init(
                top: 6,
                leading: 16,
                bottom: 6,
                trailing: 16
            )
        )
        .listRowSeparator(.hidden)
        .buttonStyle(.plain)
        .accessibilityIdentifier("ParkViewCell")
    }
}

#if DEBUG
#Preview {
    List {
        ParkRowItemView(
            imageURL: URL(string: "https://workout.su/uploads/userfiles/измайлово.jpg"),
            title: "N° 3 Легендарная / Средняя",
            address: "м. Партизанская, улица 2-я Советская",
            usersTrainHereText: "Тренируются 5 человек",
            action: { print("tap!") }
        )
        ParkRowItemView(
            imageURL: URL(string: "https://workout.su/uploads/userfiles/измайлово.jpg"),
            title: "N° 3 Легендарная / Средняя",
            address: nil,
            usersTrainHereText: "Тренируются 5 человек",
            action: { print("tap!") }
        )
    }
    .listStyle(.plain)
    .padding(.vertical)
}
#endif
