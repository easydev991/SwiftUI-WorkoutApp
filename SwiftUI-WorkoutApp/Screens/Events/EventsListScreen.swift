import SWAlert
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран со списком мероприятий
struct EventsListScreen: View {
    @EnvironmentObject private var tabViewModel: TabViewModel
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @State private var futureEvents = [EventResponse]()
    @State private var pastEvents = [EventResponse]()
    @State private var isLoading = false
    /// Выбранная вкладка с типом мероприятий
    @State private var selectedEventType = EventType.future
    /// Мероприятие для открытия детального экрана
    @State private var selectedEvent: EventResponse?
    @State private var showEventCreationSheet = false
    @State private var showEventCreationRule = false
    @State private var eventsTask: Task<Void, Never>?
    private let pastEventStorage = PastEventStorage()

    var body: some View {
        NavigationView {
            VStack {
                segmentedControl
                eventsList
                    .overlay { emptyView }
            }
            .loadingOverlay(if: isLoading)
            .background(Color.swBackground)
            .alert("Необходимо выбрать площадку", isPresented: $showEventCreationRule) {
                Button("Перейти на карту") { goToMap() }
                Button(role: .cancel, action: {}, label: { Text("Понятно") })
            } message: {
                Text(.init(Constants.Alert.eventCreationRule))
            }
            .onChange(of: selectedEventType) { _ in
                eventsTask = Task { await askForEvents() }
            }
            .onChange(of: defaults.isAuthorized) { isAuth in
                if !isAuth { selectedEvent = nil }
            }
            .refreshable { await askForEvents(refresh: true) }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    refreshButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    rightBarButton
                }
            }
            .navigationTitle("Мероприятия")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .task { await askForEvents() }
        .onDisappear { eventsTask?.cancel() }
    }
}

private extension EventsListScreen {
    var refreshButton: some View {
        Button {
            eventsTask = Task { await askForEvents(refresh: true) }
        } label: {
            Icons.Regular.refresh.view
        }
        .opacity(
            showEmptyView && !DeviceOSVersionChecker.iOS16Available ? 1 : 0
        )
        .disabled(isLoading)
    }

    var segmentedControl: some View {
        Picker("Тип мероприятия", selection: $selectedEventType) {
            ForEach(EventType.allCases, id: \.self) {
                Text(.init($0.rawValue))
                    .accessibilityIdentifier($0.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    var emptyView: some View {
        EmptyContentView(
            mode: .events,
            action: {
                if canAddEvent {
                    showEventCreationSheet.toggle()
                } else {
                    goToMap()
                }
            }
        )
        .opacity(showEmptyView ? 1 : 0)
    }

    func goToMap() { tabViewModel.selectTab(.map) }

    var eventsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(selectedEventType == .future ? futureEvents : pastEvents) { event in
                    Button {
                        selectedEvent = event
                    } label: {
                        EventRowView(
                            imageURL: event.previewImageURL,
                            title: event.formattedTitle,
                            dateTimeText: event.eventDateString,
                            locationText: SWAddress(event.countryID, event.cityID)?.cityName
                        )
                    }
                    .accessibilityIdentifier("EventViewCell")
                }
            }
            .padding([.top, .horizontal])
        }
        .opacity(isLoading ? 0 : 1)
        .sheet(item: $selectedEvent) { event in
            NavigationView {
                EventDetailsScreen(event: event) { removeEvent(id: $0) }
            }
        }
    }

    @ViewBuilder
    var rightBarButton: some View {
        if defaults.isAuthorized {
            Button {
                if defaults.hasParks {
                    showEventCreationSheet.toggle()
                } else {
                    showEventCreationRule.toggle()
                }
            } label: {
                Icons.Regular.plus.view
                    .symbolVariant(.circle)
            }
            .disabled(!isNetworkConnected)
            .sheet(isPresented: $showEventCreationSheet) {
                NavigationView {
                    EventFormScreen(
                        mode: .regularCreate,
                        refreshClbk: {
                            eventsTask = Task { await askForEvents(refresh: true) }
                        }
                    )
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            CloseButton(mode: .xmark) { showEventCreationSheet = false }
                        }
                    }
                }
            }
        }
    }

    /// Необходимо быть авторизованным и иметь сохраненные площадки, чтобы была возможность создавать мероприятия
    var canAddEvent: Bool {
        defaults.hasParks && defaults.isAuthorized
    }

    var showEmptyView: Bool {
        selectedEventType == .future && futureEvents.isEmpty && !isLoading
    }

    func askForEvents(refresh: Bool = false) async {
        let hasFutureEvents = selectedEventType == .future && !futureEvents.isEmpty
        let hasPastEvents = selectedEventType == .past && !pastEvents.isEmpty
        if isLoading && !refresh
            || (hasFutureEvents && !refresh)
            || (hasPastEvents && !refresh)
        { return }
        if !refresh { isLoading = true }
        do {
            let list = try await SWClient(with: defaults).getEvents(of: selectedEventType)
            switch selectedEventType {
            case .future: futureEvents = list
            case .past:
                pastEventStorage.saveIfNeeded(list)
                pastEvents = list
            }
        } catch {
            if selectedEventType == .past {
                pastEventStorage.loadIfNeeded(&pastEvents)
            }
            SWAlert.shared.present(message: ErrorFilter.message(from: error))
        }
        isLoading = false
    }

    func removeEvent(id: Int) {
        selectedEvent = nil
        futureEvents.removeAll(where: { $0.id == id })
        pastEvents.removeAll(where: { $0.id == id })
    }
}

#if DEBUG
#Preview {
    EventsListScreen()
        .environmentObject(TabViewModel())
        .environmentObject(DefaultsService())
}
#endif
