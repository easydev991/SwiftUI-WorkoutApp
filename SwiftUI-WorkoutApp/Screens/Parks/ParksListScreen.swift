import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран со списком площадок
struct ParksListScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @EnvironmentObject private var parksManager: ParksManager
    @State private var currentState = CurrentState.initial
    /// Площадка для открытия детального экрана
    @State private var selectedPark: Park?
    private var client: SWClient { SWClient(with: defaults) }
    let mode: Mode

    var body: some View {
        ScrollView {
            contentView
                .animation(.default, value: currentState)
                .frame(maxWidth: .infinity)
        }
        .loadingOverlay(if: currentState.isLoading)
        .background(Color.swBackground)
        .onChange(of: currentState) { newState in
            if newState.isReadyAndEmpty {
                dismiss()
            }
        }
        .task { await askForParks() }
        .refreshable {
            await askForParks(refresh: true)
        }
        .sheet(item: $selectedPark) { park in
            NavigationView {
                ParkDetailScreen(
                    park: park,
                    onEdit: updatePark,
                    onDelete: deletePark
                )
            }
            .navigationViewStyle(.stack)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                refreshButtonIfNeeded
            }
        }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension ParksListScreen {
    enum Mode {
        /// Площадки, где тренируется пользователь
        case usedBy(userId: Int)
        /// Площадки, где тренируется пользователь, для создания мероприятия
        case event(userId: Int, didSelectPark: (_ id: Int, _ name: String) -> Void)
    }
}

extension ParksListScreen {
    enum CurrentState: Equatable {
        case initial
        case loading
        case ready([Park])
        case error(ErrorKind)

        var isLoading: Bool {
            if case .loading = self { true } else { false }
        }

        /// Нужно ли загружать данные, когда их нет (или для рефреша)
        var shouldLoad: Bool {
            switch self {
            case .initial, .error: true
            case let .ready(parks): parks.isEmpty
            case .loading: false
            }
        }

        var isReadyAndNotEmpty: Bool {
            switch self {
            case let .ready(parks): !parks.isEmpty
            default: false
            }
        }

        var isReadyAndEmpty: Bool {
            if case let .ready(parks) = self { parks.isEmpty } else { false }
        }
    }
}

private extension ParksListScreen.Mode {
    var title: LocalizedStringKey {
        switch self {
        case .usedBy: "Где тренируется"
        case .event: "Твои площадки"
        }
    }
}

private extension ParksListScreen {
    @ViewBuilder
    var contentView: some View {
        switch currentState {
        case let .ready(parks):
            LazyVStack(spacing: 12) {
                ForEach(parks) { park in
                    Button {
                        switch mode {
                        case let .event(_, callBack):
                            callBack(park.id, park.name ?? park.longTitle)
                            dismiss()
                        case .usedBy:
                            selectedPark = park
                        }
                    } label: {
                        ParkRowView(
                            imageURL: park.previewImageURL,
                            title: park.longTitle,
                            address: park.address,
                            usersTrainHereText: park.usersTrainHereText
                        )
                    }
                    .accessibilityIdentifier("ParkViewCell")
                }
            }
            .padding()
        case let .error(errorKind):
            CommonErrorView(errorKind: errorKind)
        case .initial, .loading:
            EmptyView()
        }
    }

    @ViewBuilder
    var refreshButtonIfNeeded: some View {
        if !DeviceOSVersionChecker.iOS16Available {
            Button {
                Task { await askForParks(refresh: true) }
            } label: {
                Icons.Regular.refresh.view
            }
            .disabled(currentState.isLoading)
        }
    }

    func askForParks(refresh: Bool = false) async {
        switch mode {
        case let .usedBy(userId), let .event(userId, _):
            guard currentState.shouldLoad || refresh else { return }
            guard isNetworkConnected else {
                if currentState.isReadyAndNotEmpty {
                    SWAlert.shared.presentNoConnection(false)
                } else {
                    currentState = .error(.notConnected)
                }
                return
            }
            if !refresh {
                currentState = .loading
            }
            do {
                let parks = try await SWClient(with: defaults).getParksForUser(userId)
                let isMainUser = userId == defaults.mainUserInfo?.id
                if isMainUser { defaults.setUserNeedUpdate(false) }
                currentState = .ready(parks)
            } catch {
                currentState = .error(.common(message: error.localizedDescription))
            }
        }
    }

    func deletePark(id: Int) {
        selectedPark = nil
        guard case let .ready(parks) = currentState else { return }
        do {
            try parksManager.deletePark(with: id)
            let updatedParks = parks.filter { $0.id != id }
            currentState = .ready(updatedParks)
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
        }
    }

    func updatePark(_ park: Park) {
        guard case let .ready(parks) = currentState else { return }
        do {
            try parksManager.manuallyUpdatePark(park)
            let updatedParks = try parksManager.getParks(ids: parks.map(\.id))
            currentState = .ready(updatedParks)
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
        }
    }
}

#if DEBUG
#Preview {
    ParksListScreen(mode: .usedBy(userId: .previewUserId))
        .environmentObject(DefaultsService())
        .environmentObject(ParksManager())
}
#endif
