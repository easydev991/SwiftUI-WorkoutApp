//
//  EventsListView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct EventsListView: View {
    @StateObject private var viewModel = EventsListViewModel()
    @State private var selectedEventType = EventType.future
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var eventsTask: Task<Void, Never>?

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    segmentedControl
                    content
                }
                ProgressView()
                    .opacity(viewModel.isLoading ? 1 : .zero)
            }
            .navigationTitle("Мероприятия")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: selectedEventType) { _ in askForEvents() }
        .task { askForEvents() }
        .refreshable { askForEvents(refresh: true) }
        .onDisappear(perform: cancelTask)
    }
}

private extension EventsListView {
    var segmentedControl: some View {
        Picker("Тип мероприятия", selection: $selectedEventType) {
            ForEach(EventType.allCases, id: \.self) { Text($0.rawValue) }
        }
        .pickerStyle(.segmented)
        .padding()
    }

    var content: some View {
        ZStack {
            EmptyContentView(mode: .events)
                .opacity(isEmptyViewHidden ? .zero : 1)
            List(selectedEventType == .future ? viewModel.futureEvents : viewModel.pastEvents) { event in
#warning("TODO: сверстать детальный экран события")
                NavigationLink(destination: EventDetailsView(viewModel: viewModel, id: event.id)) {
                    EventViewCell(event: event)
                }
            }
            .opacity(viewModel.isLoading ? .zero : 1)
        }
    }

    var isEmptyViewHidden: Bool {
        viewModel.isEmpty(for: .future) || viewModel.isLoading || selectedEventType == .past
    }

    func askForEvents(refresh: Bool = false) {
        eventsTask = Task {
            await viewModel.askForEvents(type: selectedEventType, refresh: refresh)
        }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func cancelTask() {
        eventsTask?.cancel()
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsListView()
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 13 mini")
    }
}
