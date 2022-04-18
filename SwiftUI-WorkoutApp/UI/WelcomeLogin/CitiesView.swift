//
//  CitiesView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 17.04.2022.
//

import SwiftUI

struct CitiesView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState

    let cities: [City]
    @State private var searchQuery = ""
    private var filteredCities: [City] {
        searchQuery.isEmpty
        ? cities
        : cities.filter { $0.name.contains(searchQuery) }
    }

    var body: some View {
        List(filteredCities, id: \.self) { city in
            Button {
                appState.selectCity(city)
                presentationMode.wrappedValue.dismiss()
            } label: {
                TextWithCheckmark(
                    title: city.name,
                    showMark: city.name == $appState.selectedCity.wrappedValue.name
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

struct CitiesView_Previews: PreviewProvider {
    static var previews: some View {
        CitiesView(cities: AppState().cities)
            .environmentObject(AppState())
    }
}
