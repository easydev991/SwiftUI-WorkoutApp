import DesignSystem
import SwiftUI
import SWModels

/// Экран со списком городов
///
/// Внешне совпадает с `CountriesView`, можно позже объединить
struct CitiesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchQuery = ""
    @Binding var allCities: [City]
    let selectedCity: City
    let cityClbk: (City) -> Void

    var body: some View {
        ScrollView {
            SectionView(mode: .card()) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(zip(filteredCities.indices, filteredCities)), id: \.0) { index, city in
                        Button {
                            guard city != selectedCity else {
                                return
                            }
                            cityClbk(city)
                            dismiss()
                        } label: {
                            TextWithCheckmarkRowView(
                                text: city.name,
                                isChecked: city == selectedCity
                            )
                        }
                        .withDivider(if: index != filteredCities.endIndex - 1)
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
        .navigationTitle("Выбери город")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension CitiesView {
    var filteredCities: [City] {
        searchQuery.isEmpty
            ? allCities
            : allCities.filter { $0.name.contains(searchQuery) }
    }
}

#if DEBUG
struct CitiesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CitiesView(
                allCities: .constant([.defaultCity]),
                selectedCity: .defaultCity,
                cityClbk: { _ in }
            )
        }
    }
}
#endif
