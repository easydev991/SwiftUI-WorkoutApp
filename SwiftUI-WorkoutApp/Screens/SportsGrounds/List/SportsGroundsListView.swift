import SwiftUI

/// Экран со списком площадок, где пользователь тренируется, или которые он добавил
struct SportsGroundsListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = SportsGroundListViewModel()
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
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
                        SportsGroundDetailView(for: ground)
                    } label: {
                        SportsGroundViewCell(model: ground)
                    }
                }
            }
            .disabled(viewModel.isLoading)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
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

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }
}

struct SportsGroundListView_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundsListView(for: .usedBy(userID: DefaultsService().mainUserID))
            .environmentObject(DefaultsService())
    }
}
