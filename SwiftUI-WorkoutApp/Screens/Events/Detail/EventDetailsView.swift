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
                title
                dateInfo
                addressInfo
                mapSnapshot
                fullAddress
                makeRouteButton
                if viewModel.event.hasDescription {
                    descriptionView
                }
                linkToParticipantsView
                if defaults.isAuthorized {
                    isGoingToggle
                }
                authorSection
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
    var title: some View {
        Text(viewModel.event.formattedTitle)
            .font(.title2.bold())
    }

    var dateInfo: some View {
        HStack {
            Text("Когда")
            Spacer()
            Text(viewModel.event.eventDateString)
                .fontWeight(.medium)
        }
    }

    var mapInfo: some View {
        Section {
            MapSnapshotView(model: $viewModel.event.sportsGround)
                .frame(height: 150)
                .cornerRadius(8)
            Text(viewModel.event.fullAddress.valueOrEmpty)
            Button {
                if let url = viewModel.event.sportsGround.appleMapsURL,
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Построить маршрут")
                    .blueMediumWeight()
            }
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

    var mapSnapshot: some View {
        MapSnapshotView(model: $viewModel.event.sportsGround)
            .frame(height: 150)
            .cornerRadius(8)
    }

    var fullAddress: some View {
        Text(viewModel.event.fullAddress.valueOrEmpty)
    }

    var makeRouteButton: some View {
        Button {
            if let url = viewModel.event.sportsGround.appleMapsURL,
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        } label: {
            Text("Построить маршрут")
                .blueMediumWeight()
        }
    }

    var descriptionView: some View {
        Text(viewModel.event.formattedDescription)
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

    var authorSection: some View {
        Section("Организатор") {
            NavigationLink {
                UserProfileView(userID: viewModel.event.authorID)
            } label: {
                HStack(spacing: 16) {
                    CacheImageView(url: viewModel.event.author?.avatarURL)
                    Text(viewModel.event.name.valueOrEmpty)
                        .fontWeight(.medium)
                }
            }
            .disabled(!defaults.isAuthorized || viewModel.event.authorID == defaults.mainUserID)
        }
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
