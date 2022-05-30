import SwiftUI

/// Экран с картой и площадками
struct SportsGroundsMapView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = SportsGroundsMapViewModel()
    @State private var needUpdateRecent = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var showFilters = false
    @State private var openDetails = false

    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(isActive: $openDetails) {
                    SportsGroundDetailView(
                        for: viewModel.selectedGround,
                        onDeletion: updateDeleted
                    )
                } label: { EmptyView() }
                MapViewUI(
                    viewKey: "SportsGroundsMapView",
                    region: $viewModel.region,
                    annotations: $viewModel.list,
                    selectedPlace: $viewModel.selectedGround,
                    openDetails: $openDetails
                )
                .opacity(viewModel.isLoading ? 0.5 : 1)
                .animation(.easeInOut, value: viewModel.isLoading)
                ProgressView()
                    .opacity(viewModel.isLoading ? 1 : .zero)
            }
            .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
            .onChange(of: defaults.mainUserCountry, perform: resetFilter)
            .alert(alertMessage, isPresented: $showErrorAlert) {
                Button(action: closeAlert) { TextOk() }
            }
            .task { await askForGrounds() }
            .onAppear(perform: viewModel.onAppearAction)
            .onDisappear(perform: viewModel.onDisappearAction)
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
        await viewModel.makeGrounds(refresh: refresh)
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

    func updateRecent() {
        Task { await viewModel.checkForRecentUpdates() }
    }

    func updateDeleted(groundID: Int) {
        viewModel.deleteSportsGroundFromList()
    }

    func resetFilter(countryID: Int = .zero) {
        viewModel.resetFilter()
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
