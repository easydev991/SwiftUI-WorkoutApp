//
//  EventDetailsView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 17.05.2022.
//

import SwiftUI
#warning("TODO: сверстать детальный экран мероприятия")
struct EventDetailsView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @ObservedObject private var viewModel: EventDetailsViewModel
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var goingToEventTask: Task<Void, Never>?

    init(id: Int) {
        viewModel = .init(eventID: id)
    }

    var body: some View {
        ZStack {
            Form {
                Text(viewModel.event.formattedTitle)
                    .font(.title2.bold())
                dateInfo
                addressInfo
                linkToParticipantsView
                if defaults.isAuthorized {
                    isGoingToggle
                }
            }
            .opacity(viewModel.event.id == .zero ? .zero : 1)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .task { await viewModel.askForEvent(with: defaults) }
        .refreshable {
            await viewModel.askForEvent(refresh: true, with: defaults)
        }
        .onDisappear(perform: cancelTask)
        .navigationTitle("Мероприятие")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension EventDetailsView {
    var dateInfo: some View {
        HStack {
            Text("Когда")
            Spacer()
            Text(viewModel.event.eventDateString)
                .fontWeight(.medium)
        }
    }

    var addressInfo: some View {
        HStack {
            Text("Где")
            Spacer()
            Text(viewModel.event.shortAddress)
                .fontWeight(.medium)
        }
    }

    var linkToParticipantsView: some View {
        NavigationLink {
            UsersListView(mode: .participants(list: viewModel.event.participants ?? []))
                .navigationTitle("Пойдут на мероприятие")
        } label: {
            HStack {
                Text("Идут")
                Spacer()
                Text(
                    "peopleTrainHere \(viewModel.event.participantsCount.valueOrZero)",
                    tableName: "Plurals"
                )
                .foregroundColor(.secondary)
            }
        }
    }

    var isGoingToggle: some View {
        CustomToggle(isOn: $viewModel.isGoing, title: "Пойду на мероприятие") {
            changeIsGoingToEvent(newStatus: !viewModel.isGoing)
        }
        .disabled(viewModel.isLoading)
    }

    func changeIsGoingToEvent(newStatus: Bool) {
        goingToEventTask = Task {
            await viewModel.changeIsGoingToEvent(
                isGoing: newStatus, with: defaults
            )
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
        goingToEventTask?.cancel()
    }
}

struct EventDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailsView(id: 4378)
            .environmentObject(DefaultsService())
    }
}
