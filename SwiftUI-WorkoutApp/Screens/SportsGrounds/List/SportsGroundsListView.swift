import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран со списком площадок
struct SportsGroundsListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @EnvironmentObject private var groundsManager: SportsGroundsManager
    @State private var grounds = [SportsGround]()
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    /// Площадка для мероприятия
    @Binding private var groundInfo: SportsGround
    /// Площадка для открытия детального экрана
    @State private var selectedGround: SportsGround?
    @State private var updateGroundsTask: Task<Void, Never>?
    private let mode: Mode

    init(
        for mode: Mode,
        ground: Binding<SportsGround> = .constant(.emptyValue)
    ) {
        self.mode = mode
        _groundInfo = ground
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(grounds) { ground in
                    Button {
                        switch mode {
                        case .event:
                            groundInfo = ground
                            dismiss()
                        case .usedBy, .added:
                            selectedGround = ground
                        }
                    } label: {
                        SportsGroundRowView(
                            imageURL: ground.previewImageURL,
                            title: ground.longTitle,
                            address: ground.address,
                            usersTrainHereText: ground.usersTrainHereText
                        )
                    }
                    .accessibilityIdentifier("SportsGroundViewCell")
                }
            }
            .padding([.top, .horizontal])
        }
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .sheet(item: $selectedGround) { ground in
            NavigationView {
                SportsGroundDetailView(
                    ground: ground,
                    onDeletion: deleteGround
                )
            }
        }
        .onChange(of: grounds) { list in
            if list.isEmpty {
                defaults.setUserNeedUpdate(true)
                dismiss()
            }
        }
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button("Ok") { errorTitle = "" }
        }
        .task { await askForGrounds() }
        .refreshable {
            guard mode.canRefreshList else { return }
            await askForGrounds(refresh: true)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                refreshButtonIfNeeded
            }
        }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { updateGroundsTask?.cancel() }
    }
}

extension SportsGroundsListView {
    enum Mode {
        case usedBy(userID: Int)
        case event(userID: Int)
        case added(list: [SportsGround])

        var canRefreshList: Bool {
            switch self {
            case .added: false
            case .usedBy, .event: true
            }
        }
    }
}

private extension SportsGroundsListView.Mode {
    var title: LocalizedStringKey {
        switch self {
        case .usedBy: "Где тренируется"
        case .event: "Твои площадки"
        case .added: "Добавленные"
        }
    }
}

private extension SportsGroundsListView {
    @ViewBuilder
    var refreshButtonIfNeeded: some View {
        if !DeviceOSVersionChecker.iOS16Available {
            Button {
                updateGroundsTask = Task {
                    await askForGrounds(refresh: true)
                }
            } label: {
                Icons.Regular.refresh.view
            }
            .disabled(isLoading)
        }
    }

    func askForGrounds(refresh: Bool = false) async {
        if isLoading { return }
        do {
            switch mode {
            case let .usedBy(userID), let .event(userID):
                let isMainUser = userID == defaults.mainUserInfo?.id
                let needUpdate = grounds.isEmpty || refresh
                if isMainUser {
                    if !needUpdate, !defaults.needUpdateUser { return }
                    try await makeList(for: userID, isMainUser, refresh)
                } else {
                    if !needUpdate { return }
                    try await makeList(for: userID, isMainUser, refresh)
                }
            case let .added(list):
                grounds = list
            }
        } catch {
            setupErrorAlert(ErrorFilter.message(from: error))
        }
        isLoading = false
    }

    func makeList(for userID: Int, _ isMainUser: Bool, _ isRefreshing: Bool) async throws {
        if !isRefreshing { isLoading.toggle() }
        if isMainUser { defaults.setUserNeedUpdate(false) }
        grounds = try await SWClient(with: defaults).getSportsGroundsForUser(userID)
    }

    func deleteGround(with id: Int) {
        selectedGround = nil
        grounds.removeAll(where: { $0.id == id })
        do {
            try groundsManager.deleteGround(with: id)
            if !mode.canRefreshList {
                dismiss()
            }
        } catch {
            setupErrorAlert(error.localizedDescription)
        }
    }

    func setupErrorAlert(_ message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }
}

#if DEBUG
#Preview {
    SportsGroundsListView(for: .usedBy(userID: .previewUserID))
        .environmentObject(DefaultsService())
        .environmentObject(SportsGroundsManager())
}
#endif
