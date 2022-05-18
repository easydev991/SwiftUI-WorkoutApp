//
//  CitiesView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 17.04.2022.
//

import SwiftUI

struct CitiesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchQuery = ""
    @ObservedObject var viewModel: AccountInfoViewModel
    private var filteredCities: [City] {
        searchQuery.isEmpty
        ? viewModel.cities
        : viewModel.cities.filter { $0.name.contains(searchQuery) }
    }

    var body: some View {
        List(filteredCities) { city in
            Button {
                viewModel.selectCity(city)
                dismiss()
            } label: {
                TextWithCheckmark(
                    title: city.name,
                    showMark: city.name == viewModel.userForm.city.name
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
        CitiesView(viewModel: .init())
    }
}
