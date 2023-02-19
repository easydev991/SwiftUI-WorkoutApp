import SwiftUI
import SWModels

struct CitiesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchQuery = ""
    @Binding var allCities: [City]
    let selectedCity: City
    let cityClbk: (City) -> Void

    var body: some View {
        List(filteredCities) { city in
            Button {
                cityClbk(city)
                dismiss()
            } label: {
                TextWithCheckmark(
                    title: city.name,
                    showMark: city == selectedCity
                )
            }
        }
        .searchable(
            text: $searchQuery,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Поиск")
        )
        .navigationTitle("Выбери город")
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
        CitiesView(
            allCities: .constant([.defaultCity]),
            selectedCity: .defaultCity,
            cityClbk: { _ in }
        )
    }
}
#endif
