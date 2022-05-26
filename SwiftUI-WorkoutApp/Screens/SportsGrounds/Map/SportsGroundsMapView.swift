import SwiftUI

/// Экран с картой и площадками
struct SportsGroundsMapView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = SportsGroundsMapViewModel()
    @State private var needUpdateRecent = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(isActive: $viewModel.openDetails) {
                    SportsGroundDetailView(
                        for: viewModel.selectedGround,
                        refreshOnDelete: $needUpdateRecent
                    )
                } label: { EmptyView() }
                MapViewUI(
                    viewKey: "SportsGroundsMapView",
                    region: $viewModel.mapRegion,
                    annotations: $viewModel.list,
                    selectedPlace: $viewModel.selectedGround,
                    openDetails: $viewModel.openDetails
                )
                .opacity(viewModel.isLoading ? 0.5 : 1)
                .animation(.easeInOut, value: viewModel.isLoading)
                ProgressView()
                    .opacity(viewModel.isLoading ? 1 : .zero)
            }
            .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
            .onChange(of: needUpdateRecent, perform: updateRecent)
            .alert(alertMessage, isPresented: $showErrorAlert) {
                Button(action: closeAlert) { TextOk() }
            }
            .task { await askForGrounds() }
            .onAppear(perform: viewModel.onAppearAction)
            .onDisappear(perform: viewModel.onDisappearAction)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    refreshButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    createGroundButton
                }
            }
            .navigationTitle("Площадки")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private extension SportsGroundsMapView {
    var refreshButton: some View {
        Button(action: refreshAction) {
            Image(systemName: "arrow.triangle.2.circlepath")
        }
        .opacity(viewModel.isLoading ? .zero : 1)
    }

    func askForGrounds(refresh: Bool = false) async {
        await viewModel.makeGrounds(refresh: refresh)
    }

    func refreshAction() {
        Task { await askForGrounds(refresh: true) }
    }

    var createGroundButton: some View {
        NavigationLink {
            SportsGroundFormView(needRefreshOnSave: $needUpdateRecent)
        } label: {
            Image(systemName: "plus")
        }
        .opacity(viewModel.isLoading ? .zero : 1)
    }

    func updateRecent(isSuccess: Bool) {
        refreshAction()
#warning("TODO: удалять площадку по ID из viewModel.list без запроса к сети ")
//        Task { await viewModel.askForNewGround() }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }
}

struct SportsGroundsMapView_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundsMapView()
            .environmentObject(DefaultsService())
    }
}
