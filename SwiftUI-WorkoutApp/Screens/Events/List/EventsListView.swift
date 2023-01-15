import SwiftUI

/// Экран со списком мероприятий
struct EventsListView: View {
    @EnvironmentObject private var tabViewModel: TabViewModel
    @EnvironmentObject private var network: CheckNetworkService
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = EventsListViewModel()
    @State private var selectedEventType = EventType.future
    @State private var showEventCreationSheet = false
    @State private var showEventCreationRule = false
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
            .alert("Необходимо выбрать площадку", isPresented: $showEventCreationRule) {
                Button(action: createEventIfAvailable) { Text("Перейти на карту") }
                Button(role: .cancel, action: {}, label: { Text("Понятно") })
            } message: {
                Text(Constants.Alert.eventCreationRule)
            }
            .opacity(viewModel.isLoading ? 0.5 : 1)
            .overlay {
                ProgressView()
                    .opacity(viewModel.isLoading ? 1 : 0)
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
                    rightBarButton
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
            eventsTask = Task { await askForEvents() }
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
        }
        .opacity(showEmptyView ? 1 : 0)
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
        EmptyContentView(mode: .events, action: createEventIfAvailable)
            .opacity(showEmptyView ? 1 : 0)
            .disabled(viewModel.isLoading)
    }

    var eventsList: some View {
        List(selectedEventType == .future ? $viewModel.futureEvents : $viewModel.pastEvents) { $event in
            NavigationLink(destination: EventDetailsView(with: event, deleteClbk: refreshAction)) {
                EventViewCell(for: $event)
            }
        }
        .opacity(viewModel.isLoading ? 0 : 1)
    }

    func createEventIfAvailable() {
        if canAddEvent {
            showEventCreationSheet.toggle()
        } else {
            tabViewModel.selectTab(.map)
        }
    }

    @ViewBuilder
    var rightBarButton: some View {
        if defaults.isAuthorized {
            Button {
                if !defaults.hasSportsGrounds {
                    showEventCreationRule.toggle()
                } else {
                    createEventIfAvailable()
                }
            } label: {
                Image(systemName: "plus")
            }
            .disabled(!network.isConnected)
            .sheet(isPresented: $showEventCreationSheet) {
                ContentInSheet(title: "Новое мероприятие", spacing: .zero) {
                    EventFormView(for: .regularCreate, refreshClbk: refreshAction)
                }
            }
        } else {
            IncognitoNavbarInfoButton()
        }
    }

    /// Необходимо быть авторизованным и иметь сохраненные площадки, чтобы была возможность создавать мероприятия
    var canAddEvent: Bool {
        defaults.hasSportsGrounds && defaults.isAuthorized
    }

    var showEmptyView: Bool {
        selectedEventType == .future && viewModel.futureEvents.isEmpty
    }

    func selectedEventAction(_ type: EventType) {
        eventsTask = Task { await askForEvents() }
    }

    func askForEvents(refresh: Bool = false) async {
        await viewModel.askForEvents(type: selectedEventType, refresh: refresh, with: defaults)
    }

    func refreshAction() {
        eventsTask = Task { await askForEvents(refresh: true) }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    func closeAlert() { viewModel.clearErrorMessage() }

    func cancelTask() { eventsTask?.cancel() }
}

#if DEBUG
struct EventsListView_Previews: PreviewProvider {
    static var previews: some View {
        EventsListView()
            .environmentObject(TabViewModel())
            .environmentObject(CheckNetworkService())
            .environmentObject(DefaultsService())
    }
}
#endif
