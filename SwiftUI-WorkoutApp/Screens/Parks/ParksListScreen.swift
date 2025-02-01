import SWAlert
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран со списком площадок
struct ParksListScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @EnvironmentObject private var parksManager: ParksManager
    @State private var parks = [Park]()
    @State private var isLoading = false
    /// Площадка для открытия детального экрана
    @State private var selectedPark: Park?
    @State private var updateParksTask: Task<Void, Never>?
    let mode: Mode

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(parks) { park in
                    Button {
                        switch mode {
                        case let .event(_, callBack):
                            callBack(park.id, park.name ?? park.longTitle)
                            dismiss()
                        case .usedBy, .added:
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
            .padding([.top, .horizontal])
        }
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .sheet(item: $selectedPark) { park in
            NavigationView {
                ParkDetailScreen(park: park) { deletePark(id: $0) }
            }
        }
        .onChange(of: parks) { list in
            if list.isEmpty {
                defaults.setUserNeedUpdate(true)
                dismiss()
            }
        }
        .task { await askForParks() }
        .refreshable {
            guard mode.canRefreshList else { return }
            await askForParks(refresh: true)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                refreshButtonIfNeeded
            }
        }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { updateParksTask?.cancel() }
    }
}

extension ParksListScreen {
    enum Mode {
        case usedBy(userID: Int)
        case event(userID: Int, didSelectPark: (_ id: Int, _ name: String) -> Void)
        case added(list: [Park])

        var canRefreshList: Bool {
            switch self {
            case .added: false
            case .usedBy, .event: true
            }
        }
    }
}

private extension ParksListScreen.Mode {
    var title: LocalizedStringKey {
        switch self {
        case .usedBy: "Где тренируется"
        case .event: "Твои площадки"
        case .added: "Добавленные"
        }
    }
}

private extension ParksListScreen {
    @ViewBuilder
    var refreshButtonIfNeeded: some View {
        if !DeviceOSVersionChecker.iOS16Available {
            Button {
                updateParksTask = Task {
                    await askForParks(refresh: true)
                }
            } label: {
                Icons.Regular.refresh.view
            }
            .disabled(isLoading)
        }
    }

    func askForParks(refresh: Bool = false) async {
        if isLoading { return }
        do {
            switch mode {
            case let .usedBy(userID), let .event(userID, _):
                let isMainUser = userID == defaults.mainUserInfo?.id
                let needUpdate = parks.isEmpty || refresh
                if isMainUser {
                    if !needUpdate, !defaults.needUpdateUser { return }
                    try await makeList(for: userID, isMainUser, refresh)
                } else {
                    if !needUpdate { return }
                    try await makeList(for: userID, isMainUser, refresh)
                }
            case let .added(list):
                parks = list
            }
        } catch {
            SWAlert.shared.presentDefaultUIKit(message: error.localizedDescription)
        }
        isLoading = false
    }

    func makeList(for userID: Int, _ isMainUser: Bool, _ isRefreshing: Bool) async throws {
        if !isRefreshing { isLoading.toggle() }
        if isMainUser { defaults.setUserNeedUpdate(false) }
        parks = try await SWClient(with: defaults).getParksForUser(userID)
    }

    func deletePark(id: Int) {
        selectedPark = nil
        parks.removeAll(where: { $0.id == id })
        do {
            try parksManager.deletePark(with: id)
            if !mode.canRefreshList {
                dismiss()
            }
        } catch {
            SWAlert.shared.presentDefaultUIKit(message: error.localizedDescription)
        }
    }
}

#if DEBUG
#Preview {
    ParksListScreen(mode: .usedBy(userID: .previewUserID))
        .environmentObject(DefaultsService())
        .environmentObject(ParksManager())
}
#endif
