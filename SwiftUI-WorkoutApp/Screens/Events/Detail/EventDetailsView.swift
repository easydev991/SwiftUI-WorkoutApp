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
    @State private var changeVisitStatusTask: Task<Void, Never>?

    init(id: Int) {
        viewModel = .init(eventID: id)
    }

    var body: some View {
        ZStack {
            Form {
                Text(viewModel.event.formattedTitle)
                    .font(.title2.bold())
                if defaults.isAuthorized {
                    CustomToggle(isOn: $viewModel.isGoing, title: "Пойду на мероприятие") {
                        changeVisitEventStatus(newStatus: !viewModel.isGoing)
                    }
                    .disabled(viewModel.isLoading)
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
    func changeVisitEventStatus(newStatus: Bool) {
        changeVisitStatusTask = Task {
            await viewModel.changeVisitEventStatus(
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
        changeVisitStatusTask?.cancel()
    }
}

struct EventDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailsView(id: 4378)
            .environmentObject(DefaultsService())
    }
}
