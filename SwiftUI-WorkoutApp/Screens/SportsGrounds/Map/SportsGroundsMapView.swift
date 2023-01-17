import SwiftUI

/// Экран с картой и площадками
struct SportsGroundsMapView: View {
    @EnvironmentObject private var network: CheckNetworkService
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = SportsGroundsMapViewModel()
    @State private var presentation = Presentation.map
    @State private var needUpdateRecent = false
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
                    .disabled(viewModel.isLoading)
                    .animation(.easeInOut, value: viewModel.isLoading)
                    .overlay {
                        ProgressView()
                            .opacity(viewModel.isLoading ? 1 : 0)
                    }
            }
            .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
            .onChange(of: defaults.mainUserInfo, perform: updateFilterForUser)
            .alert(alertMessage, isPresented: $showErrorAlert) {
                Button("Ok", action: closeAlert)
            }
            .task { await askForGrounds() }
            .onAppear {
                viewModel.onAppearAction()
                updateFilterForUser(info: defaults.mainUserInfo)
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

    var segmentedControl: some View {
        Picker("Способ отображения", selection: $presentation) {
            ForEach(Presentation.allCases, id: \.self) {
                Text($0.rawValue)
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
            List(viewModel.sportsGrounds) { ground in
                NavigationLink {
                    SportsGroundDetailView(
                        for: ground,
                        onDeletion: updateDeleted
                    )
                } label: {
                    SportsGroundViewCell(model: ground)
                }
                .accessibilityIdentifier("SportsGroundViewCell")
            }
            .opacity(viewModel.isLoading ? 0.5 : 1)
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
            .opacity(mapOpacity)
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
        case .list: return .inline
        case .map: return needToHideMap ? .large : .inline
        }
    }

    var needToHideMap: Bool {
        !viewModel.isRegionSet && viewModel.ignoreUserLocation
    }

    var mapOpacity: Double {
        guard !needToHideMap else { return .zero }
        return viewModel.isLoading ? 0.5 : 1
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
                viewModel.openAppSettings()
            } label: {
                RoundedButtonLabel(title: "Открыть настройки")
            }
            .disabled(viewModel.isLoading)
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
                Image(systemName: "plus")
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
                        refreshClbk: updateRecent
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

    func updateRecent() {
        Task { await viewModel.checkForRecentUpdates(with: defaults) }
    }

    func updateDeleted(groundID: Int) {
        viewModel.deleteSportsGroundFromList(with: groundID)
    }

    /// Обновляем фильтр
    ///
    /// Параметр не используем, т.к. передаем `defaults` во вьюмодель
    func updateFilterForUser(info: UserResponse?) {
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

#if DEBUG
struct SportsGroundsMapView_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundsMapView()
            .environmentObject(CheckNetworkService())
            .environmentObject(DefaultsService())
    }
}
#endif
