import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels

/// Экран с картой и площадками
struct SportsGroundsMapView: View {
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = SportsGroundsMapViewModel()
    @State private var presentation = Presentation.map
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var showFilters = false
    @State private var showDetailsView = false
    @State private var showGroundCreationSheet = false

    var body: some View {
        NavigationView {
            VStack {
                segmentedControl
                groundsContent
                    .loadingOverlay(if: viewModel.isLoading)
            }
            .background(Color.swBackground)
            .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
            .onChange(of: defaults.mainUserInfo, perform: updateUserCountryAndCity)
            .alert(alertMessage, isPresented: $showErrorAlert) {
                Button("Ok", action: closeAlert)
            }
            .task { await askForGrounds() }
            .onAppear {
                viewModel.onAppearAction()
                updateUserCountryAndCity(with: defaults.mainUserInfo)
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
                    rightBarButton
                }
            }
            .navigationTitle("Площадки (\(viewModel.sportsGrounds.count))")
            .navigationBarTitleDisplayMode(navigationTitleDisplayMode)
        }
        .navigationViewStyle(.stack)
    }
}

private extension SportsGroundsMapView {
    /// Вариант отображения площадок на экране
    enum Presentation: String, CaseIterable, Equatable {
        case map = "Карта"
        case list = "Список"
    }

    var filterButton: some View {
        Button {
            showFilters.toggle()
        } label: {
            Image(systemName: Icons.Regular.filter.rawValue)
        }
        .sheet(isPresented: $showFilters) {
            SportsGroundFilterView(
                filter: $viewModel.filter,
                currentCity: viewModel.filter.currentCity
            )
        }
    }

    var refreshButton: some View {
        Button(action: refreshAction) {
            Image(systemName: Icons.Regular.refresh.rawValue)
        }
    }

    var segmentedControl: some View {
        Picker("Способ отображения", selection: $presentation) {
            ForEach(Presentation.allCases, id: \.self) {
                Text(LocalizedStringKey(stringLiteral: $0.rawValue))
                    .accessibilityIdentifier($0.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    @ViewBuilder
    var groundsContent: some View {
        switch presentation {
        case .list:
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.sportsGrounds) { ground in
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
                .padding([.top, .horizontal])
            }
        case .map:
            MapViewUI(
                "SportsGroundsMapView",
                viewModel.region,
                viewModel.ignoreUserLocation,
                viewModel.sportsGrounds,
                $viewModel.needUpdateAnnotations,
                $viewModel.needUpdateRegion,
                openDetailsClbk: openDetailsView
            )
            .opacity(viewModel.shouldHideMap ? 0 : 1)
            .overlay(alignment: viewModel.isRegionSet ? .bottom : .center) {
                NavigationLink(isActive: $showDetailsView) {
                    SportsGroundDetailView(
                        for: viewModel.selectedGround,
                        onDeletion: updateDeleted
                    )
                } label: { EmptyView() }
                locationSettingsReminder
            }
        }
    }

    var navigationTitleDisplayMode: NavigationBarItem.TitleDisplayMode {
        switch presentation {
        case .list: .inline
        case .map: viewModel.shouldHideMap ? .large : .inline
        }
    }

    var locationSettingsReminder: some View {
        VStack(spacing: 12) {
            Text(viewModel.locationErrorMessage)
                .foregroundColor(.swMainText)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.vertical, 12)
                .padding(.horizontal, 30)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .foregroundColor(.swBackground)
                        .withShadow()
                }
            Button("Открыть настройки") {
                viewModel.openAppSettings()
            }
            .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
        }
        .padding(.horizontal)
        .padding(.bottom, 32)
        .opacity(viewModel.ignoreUserLocation ? 1 : 0)
        .animation(.easeInOut, value: viewModel.ignoreUserLocation)
    }

    func askForGrounds(refresh: Bool = false) async {
        await viewModel.makeGrounds(refresh: refresh, with: defaults)
    }

    func refreshAction() {
        Task { await askForGrounds(refresh: true) }
    }

    @ViewBuilder
    var rightBarButton: some View {
        if defaults.isAuthorized {
            Button {
                showGroundCreationSheet.toggle()
            } label: {
                Image(systemName: Icons.Regular.plus.rawValue)
            }
            .opacity(viewModel.isLoading ? 0 : 1)
            .disabled(!network.isConnected || !viewModel.locationErrorMessage.isEmpty)
            .sheet(isPresented: $showGroundCreationSheet) {
                ContentInSheet(title: "Новая площадка", spacing: .zero) {
                    SportsGroundFormView(
                        .createNew(
                            address: viewModel.addressString,
                            coordinate: viewModel.region.center,
                            cityID: defaults.mainUserCityID
                        ),
                        refreshClbk: getNewSportsGround
                    )
                }
            }
        } else {
            IncognitoNavbarInfoButton()
        }
    }

    func openDetailsView(_ ground: SportsGround) {
        viewModel.selectedGround = ground
        showDetailsView.toggle()
    }

    func getNewSportsGround() {
        Task { await viewModel.checkForRecentUpdates(with: defaults) }
    }

    func updateDeleted(groundID: Int) {
        viewModel.deleteSportsGroundFromList(with: groundID)
    }

    func updateUserCountryAndCity(with info: UserResponse?) {
        viewModel.updateUserCountryAndCity(with: info)
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }
}

#if DEBUG
#Preview {
    SportsGroundsMapView()
        .environmentObject(NetworkStatus())
        .environmentObject(DefaultsService())
}
#endif
