import SwiftUI

/// Экран со списком площадок
struct SportsGroundsListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = SportsGroundListViewModel()
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
        ZStack {
            List(viewModel.list) { ground in
                switch mode {
                case .event:
                    Button {
                        groundInfo = ground
                        dismiss()
                    } label: {
                        SportsGroundViewCell(model: ground)
                    }
                default:
                    NavigationLink {
                        SportsGroundDetailView(
                            for: ground,
                            onDeletion: updateDeleted
                        )
                    } label: {
                        SportsGroundViewCell(model: ground)
                    }
                }
            }
            .opacity(viewModel.isLoading ? 0.5 : 1)
            .animation(.easeInOut, value: viewModel.isLoading)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .disabled(viewModel.isLoading)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: viewModel.list, perform: dismissIfEmpty)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .task { await askForGrounds() }
        .refreshable { await askForGrounds(refresh: true) }
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension SportsGroundsListView {
    enum Mode {
        case usedBy(userID: Int)
        case event(userID: Int)
        case added(list: [SportsGround])
    }
}

private extension SportsGroundsListView {
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
}

struct SportsGroundListView_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundsListView(for: .usedBy(userID: DefaultsService().mainUserID))
            .environmentObject(DefaultsService())
    }
}
