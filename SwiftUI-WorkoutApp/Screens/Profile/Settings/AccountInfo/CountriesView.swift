import DesignSystem
import SwiftUI
import SWModels

/// Экран со списком городов
///
/// Внешне совпадает с `CitiesView`, можно позже объединить
struct CountriesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchQuery = ""
    @Binding var allCountries: [Country]
    let selectedCountry: Country
    let countryClbk: (Country) -> Void

    var body: some View {
        ScrollView {
            SectionView(mode: .card()) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(zip(filteredCountries.indices, filteredCountries)), id: \.0) { index, country in
                        Button {
                            guard country != selectedCountry else {
                                return
                            }
                            countryClbk(country)
                            dismiss()
                        } label: {
                            TextWithCheckmarkRowView(
                                text: country.name,
                                isChecked: country == selectedCountry
                            )
                        }
                        .withDivider(if: index != filteredCountries.endIndex - 1)
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
        .navigationTitle("Выбери страну")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension CountriesView {
    var filteredCountries: [Country] {
        searchQuery.isEmpty
            ? allCountries
            : allCountries.filter { $0.name.contains(searchQuery) }
    }
}

#if DEBUG
struct CountriesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CountriesView(
                allCountries: .constant([.defaultCountry]),
                selectedCountry: .defaultCountry,
                countryClbk: { _ in }
            )
        }
    }
}
#endif
