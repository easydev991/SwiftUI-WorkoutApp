import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран со списком мероприятий
struct EventsListView: View {
    @EnvironmentObject private var tabViewModel: TabViewModel
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    @State private var futureEvents = [EventResponse]()
    @State private var pastEvents = [EventResponse]()
    @State private var isLoading = false
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
                eventsList
                    .overlay { emptyView }
            }
            .loadingOverlay(if: isLoading)
            .background(Color.swBackground)
            .alert("Необходимо выбрать площадку", isPresented: $showEventCreationRule) {
                Button("Перейти на карту", action: goToMap)
                Button(role: .cancel, action: {}, label: { Text("Понятно") })
            } message: {
                Text(.init(Constants.Alert.eventCreationRule))
            }
            .alert(alertMessage, isPresented: $showErrorAlert) {
                Button("Ok") { alertMessage = "" }
            }
            .onChange(of: selectedEventType) { _ in
                eventsTask = Task { await askForEvents() }
            }
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
        .onDisappear { eventsTask?.cancel() }
    }
}

private extension EventsListView {
    var refreshButton: some View {
        Button {
            eventsTask = Task { await askForEvents(refresh: true) }
        } label: {
            Image(systemName: Icons.Regular.refresh.rawValue)
        }
        .opacity(refreshButtonOpacity)
        .disabled(isLoading)
    }

    var refreshButtonOpacity: CGFloat {
        showEmptyView || !DeviceOSVersionChecker.iOS16Available ? 1 : 0
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
            isAuthorized: defaults.isAuthorized,
            hasFriends: defaults.hasFriends,
            hasSportsGrounds: defaults.hasSportsGrounds,
            isNetworkConnected: network.isConnected,
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
                ForEach(selectedEventType == .future ? $futureEvents : $pastEvents) { $event in
                    NavigationLink(destination: EventDetailsView(with: event, onDeletion: refreshAction)) {
                        EventRowView(
                            imageURL: event.previewImageURL,
                            title: event.formattedTitle,
                            dateTimeText: event.eventDateString,
                            locationText: event.cityName
                        )
                    }
                    .accessibilityIdentifier("EventViewCell")
                }
            }
            .padding([.top, .horizontal])
        }
        .opacity(isLoading ? 0 : 1)
    }

    @ViewBuilder
    var rightBarButton: some View {
        if defaults.isAuthorized {
            Button {
                if defaults.hasSportsGrounds {
                    showEventCreationSheet.toggle()
                } else {
                    showEventCreationRule.toggle()
                }
            } label: {
                Image(systemName: Icons.Regular.plus.rawValue)
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
            let list = try await SWClient(with: defaults, needAuth: false).getEvents(of: selectedEventType)
            switch selectedEventType {
            case .future: futureEvents = list
            case .past: pastEvents = list
            }
        } catch {
            if selectedEventType == .past {
                setupOldEventsFromBundle()
            }
            setupErrorAlert(with: ErrorFilter.message(from: error))
        }
        isLoading = false
    }

    func refreshAction() {
        eventsTask = Task { await askForEvents(refresh: true) }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    func setupOldEventsFromBundle() {
        do {
            let oldEvents = try Bundle.main.decodeJson(
                [EventResponse].self,
                fileName: "oldEvents",
                extension: "json"
            )
            pastEvents = oldEvents
        } catch {
            setupErrorAlert(with: ErrorFilter.message(from: error))
        }
    }
}

#if DEBUG
#Preview {
    EventsListView()
        .environmentObject(TabViewModel())
        .environmentObject(NetworkStatus())
        .environmentObject(DefaultsService())
}
#endif
