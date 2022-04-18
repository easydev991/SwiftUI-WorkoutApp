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
    @State private var searchQuery = ""
    private let countriesList = Bundle.main.decodeJson(
        [CountryElement].self,
        fileName: "countries.json"
    ).sorted { $0.name < $1.name }

    private var results: [CountryElement] {
        searchQuery.isEmpty
        ? countriesList
        : countriesList.filter { $0.name.contains(searchQuery) }
    }

    var body: some View {
        List {
            ForEach(results, id: \.self) { element in
                Button {
                    appState.select(country: element)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Text(element.name)
                        Spacer()
                        Image(systemName: "checkmark")
                            .opacity(
                                element.name == $appState.selectedCountry.wrappedValue.name
                                ? 1
                                : .zero
                            )
                    }
                }
            }
        }
        .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Поиск"))
        .navigationTitle("Выбери страну")
    }
}

struct CountriesView_Previews: PreviewProvider {
    static var previews: some View {
        CountriesView()
            .environmentObject(AppState())
    }
}
