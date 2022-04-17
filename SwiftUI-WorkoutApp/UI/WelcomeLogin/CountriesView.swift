//
//  CountriesView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 17.04.2022.
//

import SwiftUI

struct CountriesView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var searchQuery = ""

    var body: some View {
        Form {
            #warning("Добавить фильтр по алфавиту справа https://stackoverflow.com/questions/65185161/swiftui-how-to-add-letters-sections-and-alphabet-jumper-in-a-form")
            List($appState.countries, id: \.self) { element in
                Button {
                    appState.select(country: element.wrappedValue)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Text(element.wrappedValue.name)
                        Spacer()
                        Image(systemName: "checkmark")
                            .opacity(
                                element.wrappedValue.name == $appState.selectedCountry.wrappedValue.name
                                ? 1
                                : .zero
                            )
                    }
                }
            }
        }
        .navigationTitle("Выбери страну")
    }
}

struct CountriesView_Previews: PreviewProvider {
    static var previews: some View {
        CountriesView()
            .environmentObject(AppState())
    }
}
