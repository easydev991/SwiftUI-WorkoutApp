import SwiftUI

/// Экран со списком мероприятий
struct EventsListView: View {
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
                ZStack {
                    if showEmptyView {
                        emptyView
                    } else {
                        eventsList
                    }
                    ProgressView()
                        .opacity(viewModel.isLoading ? 1 : .zero)
                }
            }
            .alert(alertMessage, isPresented: $showErrorAlert) {
                Button(action: closeAlert) { TextOk() }
            }
            .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
            .onChange(of: selectedEventType, perform: selectedEventAction)
            .refreshable { await viewModel.askForEvents(type: selectedEventType, refresh: true) }
            .toolbar { addEventLink }
            .navigationTitle("Мероприятия")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task { await viewModel.askForEvents(type: selectedEventType, refresh: false) }
        .onDisappear(perform: cancelTask)
    }
}

private extension EventsListView {
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
            buttonTitle: "Создать мероприятие",
            action: createEventAction
        )
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

    func createEventAction() {
        isCreatingEvent.toggle()
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
    }

    var showAddEventButton: Bool {
        defaults.hasSportsGrounds && defaults.isAuthorized
    }

    var showEmptyView: Bool {
        viewModel.isEmpty(for: .future)
        && !viewModel.isLoading
        && selectedEventType == .future
    }

    func selectedEventAction(_ type: EventType) {
        askForEvents()
    }

    func askForEvents(refresh: Bool = false) {
        eventsTask = Task {
            await viewModel.askForEvents(type: selectedEventType, refresh: refresh)
        }
    }

    func refreshAction() {
        askForEvents(refresh: true)
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    func closeAlert() { viewModel.clearErrorMessage() }

    func cancelTask() { eventsTask?.cancel() }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsListView()
            .environmentObject(DefaultsService())
    }
}
