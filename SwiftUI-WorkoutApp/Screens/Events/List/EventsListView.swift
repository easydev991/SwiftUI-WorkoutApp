import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels

/// Экран со списком мероприятий
struct EventsListView: View {
    @EnvironmentObject private var tabViewModel: TabViewModel
    @EnvironmentObject private var network: NetworkStatus
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
                eventsList
                    .overlay { emptyView }
            }
            .loadingOverlay(if: viewModel.isLoading)
            .background(Color.swBackground)
            .alert("Необходимо выбрать площадку", isPresented: $showEventCreationRule) {
                Button(action: createEventIfAvailable) { Text("Перейти на карту") }
                Button(role: .cancel, action: {}, label: { Text("Понятно") })
            } message: {
                Text(Constants.Alert.eventCreationRule)
            }
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
            eventsTask = Task { await askForEvents(refresh: true) }
        } label: {
            Image(systemName: Icons.Regular.refresh.rawValue)
        }
        .opacity(refreshButtonOpacity)
        .disabled(viewModel.isLoading)
    }

    var refreshButtonOpacity: CGFloat {
        showEmptyView || !DeviceOSVersionChecker.iOS16Available ? 1 : 0
    }

    var segmentedControl: some View {
        Picker("Тип мероприятия", selection: $selectedEventType) {
            ForEach(EventType.allCases, id: \.self) {
                Text($0.rawValue)
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
            action: createEventIfAvailable
        )
        .opacity(showEmptyView ? 1 : 0)
        .disabled(viewModel.isLoading)
    }

    var eventsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(selectedEventType == .future ? $viewModel.futureEvents : $viewModel.pastEvents) { $event in
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
        selectedEventType == .future && viewModel.futureEvents.isEmpty && !viewModel.isLoading
    }

    func selectedEventAction(_: EventType) {
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
#Preview {
    EventsListView()
        .environmentObject(TabViewModel())
        .environmentObject(NetworkStatus())
        .environmentObject(DefaultsService())
}
#endif
