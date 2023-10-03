import SwiftUI

/// Экран со списком айтемов, где айтем - строка
///
/// Подходит для списка стран/городов
public struct ItemListScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchQuery = ""
    private let mode: Mode
    private let allItems: [String]
    private let selectedItem: String
    private let didSelectItem: (String) -> Void

    /// Инициализирует экран
    /// - Parameters:
    ///   - allItems: Список всех элементов
    ///   - selectedItem: Выбранный элемент
    ///   - didSelectItem: Возвращает выбранный элемент
    public init(
        mode: Mode,
        allItems: [String],
        selectedItem: String,
        didSelectItem: @escaping (String) -> Void
    ) {
        self.mode = mode
        self.allItems = allItems
        self.selectedItem = selectedItem
        self.didSelectItem = didSelectItem
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
                }
            }
            .padding()
        }
        .background(Color.swBackground)
        .searchable(
            text: $searchQuery,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Поиск")
        )
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

public extension ItemListScreen {
    enum Mode {
        case country, city
        var title: LocalizedStringKey {
            switch self {
            case .country: "Выбери страну"
            case .city: "Выбери город"
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
}

#if DEBUG
#Preview {
    ItemListScreen(
        mode: .country,
        allItems: ["Россия, Канада, Австралия"],
        selectedItem: "Россия",
        didSelectItem: { _ in }
    )
}
#endif
