import SwiftUI

/// Экран с картой и площадками
struct SportsGroundsMapView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = SportsGroundsMapViewModel()
    @State private var needUpdateRecent = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var showFilters = false
    @State private var showDetailsView = false

    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(isActive: $showDetailsView) {
                    SportsGroundDetailView(
                        for: viewModel.selectedGround,
                        onDeletion: updateDeleted
                    )
                } label: { EmptyView() }
                MapViewUI(
                    key: "SportsGroundsMapView",
                    region: viewModel.region,
                    annotations: $viewModel.list,
                    needUpdate: $viewModel.needUpdateAnnotations,
                    openDetails: openDetailsView
                )
                .opacity(viewModel.isLoading ? 0.5 : 1)
                .animation(.easeInOut, value: viewModel.isLoading)
                ProgressView()
                    .opacity(viewModel.isLoading ? 1 : .zero)
            }
            .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
            .onChange(of: defaults.mainUserCountry, perform: updateFilterCountry)
            .alert(alertMessage, isPresented: $showErrorAlert) {
                Button(action: closeAlert) { TextOk() }
            }
            .task { await askForGrounds() }
            .onAppear {
                viewModel.onAppearAction()
                updateFilterCountry(countryID: defaults.mainUserCountry)
            }
            .onDisappear { viewModel.onDisappearAction() }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Group {
                        filterButton
                        refreshButton
                    }
                    .disabled(viewModel.isLoading)
                }
                ToolbarItem(placement: .navigationBarLeading) {

                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if defaults.isAuthorized {
                        createGroundButton
                    }
                }
            }
            .navigationTitle("Площадки")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private extension SportsGroundsMapView {
    var filterButton: some View {
        Button {
            showFilters.toggle()
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
        .sheet(isPresented: $showFilters) {
            SportsGroundFilterView(filter: $viewModel.filter)
        }
    }
    var refreshButton: some View {
        Button(action: refreshAction) {
            Image(systemName: "arrow.triangle.2.circlepath")
        }
    }

    func askForGrounds(refresh: Bool = false) async {
        await viewModel.makeGrounds(refresh: refresh, with: defaults)
    }

    func refreshAction() {
        Task { await askForGrounds(refresh: true) }
    }

    var createGroundButton: some View {
        NavigationLink {
            SportsGroundFormView(
                .createNew(
                    address: $viewModel.addressString,
                    coordinate: $viewModel.region.center,
                    cityID: (defaults.mainUserInfo?.cityID).valueOrZero
                ),
                refreshClbk: updateRecent
            )
        } label: {
            Image(systemName: "plus")
        }
        .opacity(viewModel.isLoading ? .zero : 1)
    }

    func openDetailsView(_ ground: SportsGround) {
        viewModel.selectedGround = ground
        showDetailsView.toggle()
    }

    func updateRecent() {
        Task { await viewModel.checkForRecentUpdates(with: defaults) }
    }

    func updateDeleted(groundID: Int) {
        viewModel.deleteSportsGroundFromList()
    }

    func updateFilterCountry(countryID: Int) {
        viewModel.updateFilter(with: defaults)
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
