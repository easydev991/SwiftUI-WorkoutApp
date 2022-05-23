import SwiftUI

/// Экран с картой и площадками
struct SportsGroundsMapView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = SportsGroundsMapViewModel()
    @State private var showErrorAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(isActive: $viewModel.openDetails) {
                    SportsGroundView(mode: .limited(id: viewModel.selectedGround.id))
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
            .alert(alertMessage, isPresented: $showErrorAlert) {
                Button(action: closeAlert) { TextOk() }
            }
            .task { await askForGrounds() }
            .onAppear(perform: viewModel.onAppearAction)
            .onDisappear(perform: viewModel.onDisappearAction)
            .toolbar { refreshButton }
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
        await viewModel.makeGrounds(with: defaults, refresh: refresh)
    }

    func refreshAction() {
        Task { await askForGrounds(refresh: true) }
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
