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

    var body: some View {
        List($appState.cities, id: \.self) { city in
            Button {
                appState.select(city: city.wrappedValue)
                presentationMode.wrappedValue.dismiss()
            } label: {
                HStack {
                    Text(city.wrappedValue.name)
                    Spacer()
                    Image(systemName: "checkmark")
                        .opacity(
                            city.wrappedValue.name == $appState.selectedCity.wrappedValue.name
                            ? 1
                            : .zero
                        )
                }
            }
        }
        .navigationTitle("Выбери город")
    }
}

struct CitiesView_Previews: PreviewProvider {
    static var previews: some View {
        CountriesView()
            .environmentObject(AppState())
    }
}
