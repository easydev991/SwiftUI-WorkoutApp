//
//  CountriesView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 17.04.2022.
//

import SwiftUI

struct CountriesView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchQuery = ""
    @ObservedObject var viewModel: EditUserInfoService
    private var filteredCountries: [CountryElement] {
        searchQuery.isEmpty
        ? viewModel.countries
        : viewModel.countries.filter { $0.name.contains(searchQuery) }
    }

    var body: some View {
        List {
            ForEach(filteredCountries, id: \.self) { country in
                Button {
                    viewModel.selectCountry(country)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    TextWithCheckmark(
                        title: country.name,
                        showMark: country.name == $viewModel.selectedCity.wrappedValue.name
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
        CountriesView(viewModel: EditUserInfoService())
    }
}
