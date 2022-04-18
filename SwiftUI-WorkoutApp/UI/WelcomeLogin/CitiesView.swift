//
//  CitiesView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 17.04.2022.
//

import SwiftUI

struct CitiesView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var searchQuery = ""

    let cities: [City]
    private var results: [City] {
        searchQuery.isEmpty
        ? cities
        : cities.filter { $0.name.contains(searchQuery) }
    }

    var body: some View {
        List(results, id: \.self) { city in
            Button {
                appState.select(city: city)
                presentationMode.wrappedValue.dismiss()
            } label: {
                HStack {
                    Text(city.name)
                    Spacer()
                    Image(systemName: "checkmark")
                        .opacity(
                            city.name == $appState.selectedCity.wrappedValue.name
                            ? 1
                            : .zero
                        )
                }
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
        CountriesView()
            .environmentObject(AppState())
    }
}
