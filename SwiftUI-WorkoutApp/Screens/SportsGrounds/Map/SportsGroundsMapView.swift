import SwiftUI

/// Экран с картой и площадками
struct SportsGroundsMapView: View {
    @EnvironmentObject private var network: CheckNetworkService
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = SportsGroundsMapViewModel()
    @State private var needUpdateRecent = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var showFilters = false
    @State private var showDetailsView = false
    @State private var showGroundCreationSheet = false

    var body: some View {
        NavigationView {
            ZStack {
                MapViewUI(
                    "SportsGroundsMapView",
                    viewModel.region,
                    viewModel.sportsGrounds,
                    $viewModel.needUpdateAnnotations,
                    $viewModel.needUpdateRegion,
                    $viewModel.ignoreUserLocation,
                    openDetailsClbk: openDetailsView
                )
                .opacity(mapOpacity)
                .animation(.easeInOut, value: viewModel.isLoading)
                ProgressView()
                    .opacity(viewModel.isLoading ? 1 : .zero)
            }
            .overlay(alignment: viewModel.isRegionSet ? .bottom : .center) {
                NavigationLink(isActive: $showDetailsView) {
                    SportsGroundDetailView(
                        for: viewModel.selectedGround,
                        onDeletion: updateDeleted
                    )
                } label: { EmptyView() }
                locationSettingsReminder
            }
            .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
            .onChange(of: defaults.mainUserCountry, perform: updateFilterCountry)
            .alert(alertMessage, isPresented: $showErrorAlert) {
                Button("Ok", action: closeAlert)
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
                    .disabled(isLeftToolbarPartDisabled)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if defaults.isAuthorized {
                        createGroundButton
                    }
                }
            }
            .navigationTitle("Площадки")
            .navigationBarTitleDisplayMode(needToHideMap ? .large : .inline)
        }
        .navigationViewStyle(.stack)
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

    var needToHideMap: Bool {
        !viewModel.isRegionSet && viewModel.ignoreUserLocation
    }

    var mapOpacity: Double {
        if needToHideMap {
            return .zero
        }
        if viewModel.isLoading {
            return 0.5
        } else {
            return 1
        }
    }

    var isLeftToolbarPartDisabled: Bool {
        viewModel.isRegionSet
        ? viewModel.isLoading
        : viewModel.isLoading || viewModel.ignoreUserLocation
    }

    var locationSettingsReminder: some View {
        VStack {
            Text(viewModel.locationErrorMessage)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color("ButtonTitle"))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .background(Color("ButtonBackground").cornerRadius(8))
            Button {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL)
                }
            } label: {
                Text("Открыть настройки")
                    .roundedRectangleStyle()
            }
            .disabled(viewModel.isLoading)
        }
        .padding(.horizontal)
        .padding(.bottom, 32)
        .opacity(viewModel.ignoreUserLocation ? 1 : .zero)
        .animation(.easeInOut, value: viewModel.ignoreUserLocation)
    }

    func askForGrounds(refresh: Bool = false) async {
        await viewModel.makeGrounds(refresh: refresh, with: defaults)
    }

    func refreshAction() {
        Task { await askForGrounds(refresh: true) }
    }

    var createGroundButton: some View {
        Button {
            showGroundCreationSheet.toggle()
        } label: {
            Image(systemName: "plus")
        }
        .opacity(viewModel.isLoading ? .zero : 1)
        .disabled(!network.isConnected || !viewModel.locationErrorMessage.isEmpty)
        .sheet(isPresented: $showGroundCreationSheet) {
            ContentInSheet(title: "Новая площадка", spacing: .zero) {
                SportsGroundFormView(
                    .createNew(
                        address: $viewModel.addressString,
                        coordinate: $viewModel.region.center,
                        cityID: (defaults.mainUserInfo?.cityID).valueOrZero
                    ),
                    refreshClbk: updateRecent
                )
            }
        }
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
            .environmentObject(CheckNetworkService())
            .environmentObject(DefaultsService())
    }
}
