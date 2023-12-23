import FileManager991
import MapView991
import NetworkStatus
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import Utils

/// Экран с картой и площадками
struct SportsGroundsMapView: View {
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    @EnvironmentObject private var groundsManager: SportsGroundsManager
    @StateObject private var viewModel = SportsGroundsMapViewModel()
    @State private var presentation = Presentation.map
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var sheetItem: SheetItem?
    @State private var filter = SportsGroundFilterView.Model()
    /// Город для фильтра списка площадок
    @State private var selectedCity: City?
    /// Отфильтрованные площадки для вкладки "Карта"
    private var filteredMapGrounds: [SportsGround] {
        groundsManager.fullList.filter { ground in
            filter.size.map(\.code).contains(ground.sizeID)
                && filter.grade.map(\.code).contains(ground.typeID)
        }
    }

    /// Отфильтрованные по выбранному городу площадки для вкладки "Список"
    private var filteredListGrounds: [SportsGround] {
        if let selectedCity {
            filteredMapGrounds.filter { $0.cityID == Int(selectedCity.id) }
        } else {
            filteredMapGrounds
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                segmentedControl
                groundsContent
            }
            .loadingOverlay(if: isLoading)
            .background(Color.swBackground)
            .onChange(of: defaults.mainUserCityID) { _ in
                viewModel.updateUserCountryAndCity(with: defaults.mainUserInfo)
            }
            .alert(alertMessage, isPresented: $showErrorAlert) {
                Button("Ok") { alertMessage = "" }
            }
            .task { await askForGrounds() }
            .sheet(item: $sheetItem) { makeContentView(for: $0) }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Group {
                        filterButton
                        Button {
                            Task { await askForGrounds(refresh: true) }
                        } label: {
                            Icons.Regular.refresh.view
                        }
                    }
                    .disabled(isLoading)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    rightBarButton
                }
            }
            .navigationTitle("Площадки (\(currentGroundsCount))")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
}

private extension SportsGroundsMapView {
    enum SheetItem: Identifiable {
        var id: String {
            switch self {
            case .filters: "filters"
            case .searchCity: "searchCity"
            case .createNewGround: "createNewGround"
            case let .groundDetails(sportsGround): sportsGround.longTitle
            }
        }

        /// Базовые фильтры площадок
        case filters
        /// Поиск города в списке городов
        case searchCity([City])
        /// Создание новой площадки
        case createNewGround
        /// Площадка для открытия детального экрана
        case groundDetails(SportsGround)
    }
}

private extension SportsGroundsMapView {
    /// Вариант отображения площадок на экране
    enum Presentation: String, CaseIterable, Equatable {
        case map = "Карта"
        case list = "Список"
    }

    var currentGroundsCount: Int {
        switch presentation {
        case .map: filteredMapGrounds.count
        case .list: filteredListGrounds.count
        }
    }

    var filterButton: some View {
        Button {
            sheetItem = .filters
        } label: {
            Icons.Regular.filter.view
                .symbolVariant(filter.isEdited ? .fill : .none)
        }
    }

    var segmentedControl: some View {
        Picker("Способ отображения", selection: $presentation) {
            ForEach(Presentation.allCases, id: \.self) {
                Text(.init($0.rawValue))
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
            VStack(spacing: 16) {
                if let storedCities = try? SWAddress().cities() {
                    SWTextFieldSearchButton(
                        selectedCity == nil ? "Выбери город" : "\(selectedCity!.name)",
                        showClearButton: selectedCity != nil,
                        mainAction: { sheetItem = .searchCity(storedCities) },
                        clearAction: { selectedCity = nil }
                    )
                    .padding(.horizontal)
                }
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredListGrounds) { ground in
                            Button {
                                sheetItem = .groundDetails(ground)
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
                    .padding(.horizontal)
                }
            }
        case .map:
            MapView991(
                region: viewModel.region,
                hideTrackingButton: viewModel.ignoreUserLocation,
                annotations: filteredMapGrounds.map(\.annotation),
                didSelect: { annotation in
                    if let ground = filteredMapGrounds.first(
                        where: { $0.annotation.title == annotation.title }
                    ) {
                        sheetItem = .groundDetails(ground)
                    }
                }
            )
            .opacity(viewModel.shouldHideMap ? 0 : 1)
            .overlay(alignment: viewModel.isRegionSet ? .bottom : .center) {
                LocationSettingReminderView(
                    message: viewModel.locationErrorMessage,
                    isHidden: !viewModel.ignoreUserLocation
                )
            }
        }
    }

    /// Заполняем/обновляем дефолтный список площадок
    func askForGrounds(refresh: Bool = false) async {
        if !filteredMapGrounds.isEmpty, !refresh { return }
        guard !groundsManager.fullList.isEmpty else {
            // Заполняем дефолтный список площадок контентом из `json`-файла
            do {
                try groundsManager.makeDefaultList()
            } catch {
                setupErrorAlert(error.localizedDescription)
            }
            // Если прошло больше одного дня с момента предыдущего обновления, делаем обновление
            if groundsManager.needUpdateDefaultList {
                await askForGrounds(refresh: true)
            }
            return
        }
        await getUpdatedGrounds(from: groundsManager.lastGroundsUpdateDateString)
    }

    func deleteGround(id: Int) {
        sheetItem = nil
        do {
            try groundsManager.deleteGround(with: id)
        } catch {
            setupErrorAlert(error.localizedDescription)
        }
    }

    /// Проверяем недавние обновления списка площадок
    ///
    /// Запрашиваем обновление за прошедшие 5 минут
    func checkForRecentUpdates() async {
        defaults.setUserNeedUpdate(true)
        await getUpdatedGrounds(from: DateFormatterService.fiveMinutesAgoDateString)
    }

    func getUpdatedGrounds(from dateString: String) async {
        isLoading = true
        do {
            let updatedGrounds = try await SWClient(with: defaults, needAuth: false).getUpdatedSportsGrounds(
                from: dateString
            )
            try groundsManager.updateDefaultList(with: updatedGrounds)
        } catch {
            setupErrorAlert(ErrorFilter.message(from: error))
        }
        isLoading = false
    }

    @ViewBuilder
    var rightBarButton: some View {
        if defaults.isAuthorized {
            Button {
                sheetItem = .createNewGround
            } label: {
                Icons.Regular.plus.view
                    .symbolVariant(.circle)
            }
            .opacity(isLoading ? 0 : 1)
            .disabled(!network.isConnected || !viewModel.locationErrorMessage.isEmpty)
        }
    }

    @ViewBuilder
    func makeContentView(for item: SheetItem) -> some View {
        switch item {
        case .filters:
            SportsGroundFilterView(filter: $filter)
        case .createNewGround:
            ContentInSheet(title: "Новая площадка", spacing: 0) {
                SportsGroundFormView(
                    .createNew(
                        address: viewModel.addressString,
                        coordinate: viewModel.region.center,
                        cityID: defaults.mainUserCityID
                    ),
                    refreshClbk: {
                        Task {
                            await checkForRecentUpdates()
                        }
                    }
                )
            }
        case let .searchCity(storedCities):
            NavigationView {
                ItemListScreen(
                    mode: .city,
                    allItems: storedCities.map(\.name),
                    selectedItem: selectedCity?.name ?? "",
                    didSelectItem: { cityName in
                        selectedCity = storedCities.first(where: { $0.name == cityName })
                    }
                )
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        CloseButton(mode: .xmark) { sheetItem = nil }
                    }
                }
            }
        case let .groundDetails(ground):
            NavigationView {
                SportsGroundDetailView(ground: ground) { deleteGround(id: $0) }
            }
        }
    }

    func setupErrorAlert(_ message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }
}

#if DEBUG
#Preview {
    SportsGroundsMapView()
        .environmentObject(NetworkStatus())
        .environmentObject(DefaultsService())
        .environmentObject(SportsGroundsManager())
}
#endif
