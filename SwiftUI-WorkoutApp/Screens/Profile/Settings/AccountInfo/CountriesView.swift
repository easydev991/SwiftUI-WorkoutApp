import SwiftUI

struct CountriesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchQuery = ""
    @Binding var allCountries: [Country]
    let selectedCountry: Country
    let countryClbk: (Country) -> Void

    var body: some View {
        List {
            ForEach(filteredCountries) { country in
                Button {
                    countryClbk(country)
                    dismiss()
                } label: {
                    TextWithCheckmark(
                        title: country.name,
                        showMark: country == selectedCountry
                    )
                }
            }
        }
        .searchable(
            text: $searchQuery,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Поиск")
        )
        .navigationTitle("Выбери страну")
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
        CountriesView(
            allCountries: .constant([.defaultCountry]),
            selectedCountry: .defaultCountry,
            countryClbk: { _ in }
        )
    }
}
#endif
