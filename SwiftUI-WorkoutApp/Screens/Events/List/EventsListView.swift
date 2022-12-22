import SwiftUI

/// Экран со списком мероприятий
struct EventsListView: View {
    @EnvironmentObject private var tabViewModel: TabViewModel
    @EnvironmentObject private var network: CheckNetworkService
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = EventsListViewModel()
    @State private var selectedEventType = EventType.future
    @State private var isCreatingEvent = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var eventsTask: Task<Void, Never>?

    var body: some View {
        NavigationView {
            VStack {
                segmentedControl
                if showEmptyView {
                    emptyView
                } else {
                    eventsList
                }
            }
            .opacity(viewModel.isLoading ? 0.5 : 1)
            .overlay {
                ProgressView()
                    .opacity(viewModel.isLoading ? 1 : .zero)
            }
            .animation(.default, value: viewModel.isLoading)
            .alert(alertMessage, isPresented: $showErrorAlert) {
                Button("Ok", action: closeAlert)
            }
            .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
            .onChange(of: selectedEventType, perform: selectedEventAction)
            .refreshable { await askForEvents(refresh: true) }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    refreshButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    addEventLink
                }
            }
            .navigationTitle("Мероприятия")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .task { await askForEvents() }
        .onDisappear(perform: cancelTask)
    }
}

private extension EventsListView {
    var refreshButton: some View {
        Button {
            eventsTask = Task {
                await askForEvents()
            }
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
        }
        .opacity(showEmptyView ? 1 : .zero)
        .disabled(viewModel.isLoading)
    }

    var segmentedControl: some View {
        Picker("Тип мероприятия", selection: $selectedEventType) {
            ForEach(EventType.allCases, id: \.self) { Text($0.rawValue) }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    var emptyView: some View {
        EmptyContentView(
            message: "Нет запланированных мероприятий",
            buttonTitle: emptyViewButtonTitle,
            action: emptyViewAction,
            hintText: emptyViewHintText
        )
        .opacity(showEmptyView ? 1 : .zero)
        .disabled(viewModel.isLoading)
    }

    var emptyViewButtonTitle: String {
        showAddEventButton ? "Создать мероприятие" : "Выбрать площадку"
    }

    var emptyViewHintText: String {
        if !defaults.isAuthorized {
            return ""
        } else {
            return showAddEventButton
            ? ""
            : "Чтобы создать мероприятие, нужно указать хотя бы одну площадку, где ты тренируешься"
        }
    }

    var eventsList: some View {
        List(selectedEventType == .future ? $viewModel.futureEvents : $viewModel.pastEvents) { $event in
            NavigationLink {
                EventDetailsView(with: event, deleteClbk: refreshAction)
            } label: {
                EventViewCell(for: $event)
            }
        }
        .opacity(viewModel.isLoading ? .zero : 1)
    }

    func emptyViewAction() {
        if showAddEventButton {
            isCreatingEvent.toggle()
        } else {
            tabViewModel.selectTab(.map)
        }
    }

    var addEventLink: some View {
        NavigationLink(isActive: $isCreatingEvent) {
            EventFormView(
                for: .regularCreate,
                refreshClbk: refreshAction
            )
        } label: {
            Image(systemName: "plus")
        }
        .opacity(showAddEventButton ? 1 : .zero)
        .disabled(!network.isConnected)
    }

    var showAddEventButton: Bool {
        defaults.hasSportsGrounds
        && defaults.isAuthorized
    }

    var showEmptyView: Bool {
        selectedEventType == .future
        && viewModel.futureEvents.isEmpty
    }

    func selectedEventAction(_ type: EventType) {
        eventsTask = Task {
            await askForEvents()
        }
    }

    func askForEvents(refresh: Bool = false) async {
        await viewModel.askForEvents(type: selectedEventType, refresh: refresh, with: defaults)
    }

    func refreshAction() {
        eventsTask = Task {
            await askForEvents(refresh: true)
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
            .environmentObject(TabViewModel())
            .environmentObject(CheckNetworkService())
            .environmentObject(DefaultsService())
    }
}
