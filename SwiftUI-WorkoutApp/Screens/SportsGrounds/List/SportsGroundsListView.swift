import DesignSystem
import SwiftUI
import SWModels

/// Экран со списком площадок
struct SportsGroundsListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = SportsGroundListViewModel()
    @State private var updateGroundsTask: Task<Void, Never>?
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    /// Площадка для мероприятия
    @Binding private var groundInfo: SportsGround
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
                ForEach(viewModel.list) { ground in
                    switch mode {
                    case .event:
                        Button {
                            groundInfo = ground
                            dismiss()
                        } label: {
                            SportsGroundRowView(
                                imageURL: ground.previewImageURL,
                                title: ground.longTitle,
                                address: ground.address,
                                usersTrainHereText: ground.usersTrainHereText
                            )
                        }
                        .accessibilityIdentifier("SportsGroundViewCell")
                    default:
                        NavigationLink {
                            SportsGroundDetailView(
                                for: ground,
                                onDeletion: updateDeleted
                            )
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
            }
            .padding([.top, .horizontal])
        }
        .loadingOverlay(if: viewModel.isLoading)
        .background(Color.swBackground)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: viewModel.list, perform: dismissIfEmpty)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button("Ok", action: closeAlert)
        }
        .task { await askForGrounds() }
        .refreshable { await askForGrounds(refresh: true) }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                refreshButtonIfNeeded
            }
        }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear(perform: cancelTask)
    }
}

extension SportsGroundsListView {
    enum Mode {
        case usedBy(userID: Int)
        case event(userID: Int)
        case added(list: [SportsGround])
    }
}

private extension SportsGroundsListView.Mode {
    var title: String {
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
                Image(systemName: Icons.Regular.refresh.rawValue)
            }
            .disabled(viewModel.isLoading)
        }
    }

    func askForGrounds(refresh: Bool = false) async {
        await viewModel.makeSportsGroundsFor(mode, refresh: refresh, with: defaults)
    }

    func updateDeleted(deletedGroundId: Int) {
        viewModel.deleteSportsGround(id: deletedGroundId)
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func dismissIfEmpty(list: [SportsGround]) {
        if list.isEmpty {
            defaults.setUserNeedUpdate(true)
            dismiss()
        }
    }

    func cancelTask() {
        updateGroundsTask?.cancel()
    }
}

#if DEBUG
#Preview {
    SportsGroundsListView(for: .usedBy(userID: .previewUserID))
        .environmentObject(DefaultsService())
}
#endif
