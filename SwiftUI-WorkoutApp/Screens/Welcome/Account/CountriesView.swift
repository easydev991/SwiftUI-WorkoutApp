import SwiftUI

struct CountriesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchQuery = ""
    @ObservedObject var viewModel: AccountInfoViewModel
    private var filteredCountries: [Country] {
        searchQuery.isEmpty
        ? viewModel.countries
        : viewModel.countries.filter { $0.name.contains(searchQuery) }
    }

    var body: some View {
        List {
            ForEach(filteredCountries) { country in
                Button {
                    viewModel.selectCountry(country)
                    dismiss()
                } label: {
                    TextWithCheckmark(
                        title: country.name,
                        showMark: country.name == viewModel.userForm.country.name
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

struct CountriesView_Previews: PreviewProvider {
    static var previews: some View {
        CountriesView(viewModel: .init())
    }
}
