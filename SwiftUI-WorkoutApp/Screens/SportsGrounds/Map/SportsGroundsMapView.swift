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

    var body: some View {
        NavigationView {
            ZStack {
                MapViewUI(
                    key: "SportsGroundsMapView",
                    region: viewModel.region,
                    annotations: $viewModel.sportsGrounds,
                    needUpdateAnnotations: $viewModel.needUpdateAnnotations,
                    needUpdateRegion: $viewModel.needUpdateRegion,
                    openDetails: openDetailsView
                )
                .opacity(viewModel.isLoading ? 0.5 : 1)
                .overlay(alignment: .bottom) {
                    NavigationLink(isActive: $showDetailsView) {
                        SportsGroundDetailView(
                            for: viewModel.selectedGround,
                            onDeletion: updateDeleted
                        )
                    } label: { EmptyView() }
                    locationSettingsReminder
                }
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
                    .padding(.bottom, 32)
            }
            .disabled(viewModel.isLoading)
        }
        .padding()
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
        .disabled(!network.isConnected || !viewModel.locationErrorMessage.isEmpty)
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
