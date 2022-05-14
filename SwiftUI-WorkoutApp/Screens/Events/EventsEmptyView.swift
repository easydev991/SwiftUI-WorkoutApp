//
//  EventsEmptyView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 03.05.2022.
//

import SwiftUI

struct EventsEmptyView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Нет запланированных мероприятий")
                .font(.title2)
                .multilineTextAlignment(.center)
            Image(systemName: "calendar")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.secondary)
                .frame(width: 180)
            NavigationLink(destination: CreateEventView(viewModel: .init(mode: .regular))) {
                Text("Создать мероприятие")
                    .font(.headline)
                    .frame(height: 48)
                    .padding(.horizontal)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke()
                    }
            }
            Spacer()
        }
        .padding()
    }
}

struct EventsEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        EventsEmptyView()
    }
}
