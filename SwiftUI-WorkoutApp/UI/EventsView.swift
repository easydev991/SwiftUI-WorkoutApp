//
//  EventsView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct EventsView: View {
    var body: some View {
        NavigationView {
            Text("Мероприятия")
                .navigationTitle("Мероприятия")
        }
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
    }
}
