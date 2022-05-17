//
//  EventDetailsView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 17.05.2022.
//

import SwiftUI

struct EventDetailsView: View {
    @ObservedObject var viewModel: EventsListViewModel
    let id: Int
    var body: some View {
        Text(viewModel.eventInfo.formattedTitle)
            .task { await viewModel.askForEvent(id: id) }
            .refreshable {
                await viewModel.askForEvent(id: id, refresh: true)
            }
            .navigationTitle("Мероприятие")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct EventDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailsView(viewModel: .init(), id: 4378)
    }
}
