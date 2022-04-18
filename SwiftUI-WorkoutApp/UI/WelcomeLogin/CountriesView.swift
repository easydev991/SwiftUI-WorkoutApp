//
//  CountriesView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 17.04.2022.
//

import SwiftUI

struct CountriesView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState

    let countriesList: [CountryElement]
    @State private var searchQuery = ""
    private var filteredCountries: [CountryElement] {
        searchQuery.isEmpty
        ? countriesList
        : countriesList.filter { $0.name.contains(searchQuery) }
    }

    var body: some View {
        List {
            ForEach(filteredCountries, id: \.self) { country in
                Button {
                    appState.selectCountry(country)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    TextWithCheckmark(
                        title: country.name,
                        showMark: country.name == $appState.selectedCity.wrappedValue.name
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
        CountriesView(countriesList: AppState().countries)
            .environmentObject(AppState())
    }
}
