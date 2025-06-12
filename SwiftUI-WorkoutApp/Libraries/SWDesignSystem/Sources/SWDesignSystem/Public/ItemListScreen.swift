import SwiftUI

/// Экран со списком айтемов, где айтем - строка, которую можно выбрать
///
/// Используется для списка стран/городов
public struct ItemListScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchQuery = ""
    private let mode: Mode
    private let allItems: [String]
    private let selectedItem: String
    private let didTapContactUs: (_ mode: Mode) -> Void
    private let didSelectItem: (String) -> Void

    /// Инициализирует экран
    /// - Parameters:
    ///   - allItems: Список всех элементов
    ///   - selectedItem: Выбранный элемент
    ///   - didSelectItem: Возвращает выбранный элемент
    ///   - didTapContactUs: Замыкание для перехода в почту,
    ///   чтобы сообщить о стране/городе, который нужно добавить в базу
    public init(
        mode: Mode,
        allItems: [String],
        selectedItem: String,
        didSelectItem: @escaping (String) -> Void,
        didTapContactUs: @escaping (_ mode: Mode) -> Void
    ) {
        self.mode = mode
        self.allItems = allItems
        self.selectedItem = selectedItem
        self.didSelectItem = didSelectItem
        self.didTapContactUs = didTapContactUs
    }

    public var body: some View {
        ScrollView {
            SectionView(mode: .card()) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(zip(filteredItems.indices, filteredItems)), id: \.0) { index, item in
                        Button {
                            guard item != selectedItem else { return }
                            didSelectItem(item)
                            dismiss()
                        } label: {
                            TextWithCheckmarkRowView(
                                text: .init(item),
                                isChecked: item == selectedItem
                            )
                        }
                        .withDivider(if: index != filteredItems.endIndex - 1)
                    }
                    if filteredItems.isEmpty {
                        emptyStateView
                    }
                }
            }
            .animation(.default, value: filteredItems.isEmpty)
            .padding()
        }
        .background(Color.swBackground)
        .searchable(
            text: $searchQuery,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Search", bundle: .module)
        )
        .navigationTitle(Text(mode.title, bundle: .module))
        .navigationBarTitleDisplayMode(.inline)
    }
}

public extension ItemListScreen {
    enum Mode {
        case country, city
        var title: LocalizedStringKey {
            switch self {
            case .country: "Pick a country"
            case .city: "Pick a city"
            }
        }
        var helpMessage: LocalizedStringKey {
            switch self {
            case .country: "Help.CountryNotFound"
            case .city: "Help.CityNotFound"
            }
        }
    }
}

private extension ItemListScreen {
    var filteredItems: [String] {
        searchQuery.isEmpty
            ? allItems
            : allItems.filter { $0.contains(searchQuery) }
    }
    
    var emptyStateView: some View {
        HStack(spacing: 12) {
            Text(mode.helpMessage, bundle: .module)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                didTapContactUs(mode)
            } label: {
                Text("Contact us", bundle: .module)
            }
            .buttonStyle(
                SWButtonStyle(mode: .filled, size: .small, maxWidth: nil)
            )
        }
        .padding(12)
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview("Поиск страны") {
    @Previewable @State var selectedItem: String = "Россия"
    NavigationStack {
        ItemListScreen(
            mode: .country,
            allItems: ["Россия", "Канада", "Австралия"],
            selectedItem: selectedItem,
            didSelectItem: { newItem in selectedItem = newItem },
            didTapContactUs: { _ in }
        )
    }
    .environment(\.locale, .init(identifier: "ru"))
}

@available(iOS 17.0, *)
#Preview("Поиск города") {
    @Previewable @State var selectedItem: String = "Москва"
    NavigationStack {
        ItemListScreen(
            mode: .city,
            allItems: ["Москва", "Киров", "Волгоград"],
            selectedItem: selectedItem,
            didSelectItem: { newItem in selectedItem = newItem },
            didTapContactUs: { _ in }
        )
    }
    .environment(\.locale, .init(identifier: "ru"))
}
#endif
