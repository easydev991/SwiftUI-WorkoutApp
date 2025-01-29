import FileManager991
import MapView991
import SWAlert
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import Utils

/// Экран с картой и площадками
struct ParksMapScreen: View {
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @EnvironmentObject private var parksManager: ParksManager
    @StateObject private var viewModel = ViewModel()
    @State private var presentation = Presentation.map
    @State private var isLoading = false
    @State private var sheetItem: SheetItem?
    @State private var filter = ParkFilterScreen.Model()
    /// Город для фильтра списка площадок
    @State private var selectedCity: City?
    /// Отфильтрованные площадки для вкладки "Карта"
    private var filteredMapParks: [Park] {
        parksManager.fullList.filter { park in
            filter.size.map(\.code).contains(park.sizeID)
                && filter.grade.map(\.code).contains(park.typeID)
        }
    }

    /// Отфильтрованные по выбранному городу площадки для вкладки "Список"
    private var filteredListParks: [Park] {
        if let selectedCity {
            filteredMapParks.filter { $0.cityID == Int(selectedCity.id) }
        } else {
            filteredMapParks
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                segmentedControl
                parksContent
            }
            .loadingOverlay(if: isLoading)
            .background(Color.swBackground)
            .onChange(of: defaults.mainUserCityID) { _ in
                viewModel.updateUserCountryAndCity(with: defaults.mainUserInfo)
            }
            .task { await askForParks() }
            .sheet(item: $sheetItem) { makeContentView(for: $0) }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Group {
                        filterButton
                        Button {
                            Task { await askForParks(refresh: true) }
                        } label: {
                            Icons.Regular.refresh.view
                        }
                    }
                    .disabled(isLoading)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    rightBarButton
                }
            }
            .navigationTitle("Площадки (\(currentParksCount))")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
}

private extension ParksMapScreen {
    enum SheetItem: Identifiable {
        var id: String {
            switch self {
            case .filters: "filters"
            case .searchCity: "searchCity"
            case .createNewPark: "createNewPark"
            case let .parkDetails(park): park.longTitle
            }
        }

        /// Базовые фильтры площадок
        case filters
        /// Поиск города в списке городов
        case searchCity([City])
        /// Создание новой площадки
        case createNewPark
        /// Площадка для открытия детального экрана
        case parkDetails(Park)
    }
}

private extension ParksMapScreen {
    /// Вариант отображения площадок на экране
    enum Presentation: String, CaseIterable, Equatable {
        case map = "Карта"
        case list = "Список"
    }

    var currentParksCount: Int {
        switch presentation {
        case .map: filteredMapParks.count
        case .list: filteredListParks.count
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
    var parksContent: some View {
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
                        ForEach(filteredListParks) { park in
                            Button {
                                sheetItem = .parkDetails(park)
                            } label: {
                                ParkRowView(
                                    imageURL: park.previewImageURL,
                                    title: park.longTitle,
                                    address: park.address,
                                    usersTrainHereText: park.usersTrainHereText
                                )
                            }
                            .accessibilityIdentifier("ParkViewCell")
                        }
                    }
                    .padding(.horizontal)
                }
            }
        case .map:
            MapView991(
                region: viewModel.region,
                hideTrackingButton: viewModel.ignoreUserLocation,
                annotations: filteredMapParks.map(\.annotation),
                didSelect: { annotation in
                    if let park = filteredMapParks.first(
                        where: { $0.annotation.title == annotation.title }
                    ) {
                        sheetItem = .parkDetails(park)
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
    func askForParks(refresh: Bool = false) async {
        if !filteredMapParks.isEmpty, !refresh { return }
        guard !parksManager.fullList.isEmpty else {
            // Заполняем дефолтный список площадок контентом из `json`-файла
            do {
                try parksManager.makeDefaultList()
            } catch {
                SWAlert.shared.presentDefaultUIKit(message: error.localizedDescription)
            }
            // Если прошло больше одного дня с момента предыдущего обновления, делаем обновление
            if parksManager.needUpdateDefaultList {
                await askForParks(refresh: true)
            }
            return
        }
        await getUpdatedParks(from: parksManager.lastParksUpdateDateString)
    }

    func deletePark(id: Int) {
        sheetItem = nil
        do {
            try parksManager.deletePark(with: id)
        } catch {
            SWAlert.shared.presentDefaultUIKit(message: error.localizedDescription)
        }
    }

    /// Проверяем недавние обновления списка площадок
    ///
    /// Запрашиваем обновление за прошедшие 5 минут
    func checkForRecentUpdates() async {
        defaults.setUserNeedUpdate(true)
        await getUpdatedParks(from: DateFormatterService.fiveMinutesAgoDateString)
    }

    func getUpdatedParks(from dateString: String) async {
        isLoading = true
        do {
            let updatedParks = try await SWClient(with: defaults).getUpdatedParks(from: dateString)
            try parksManager.updateDefaultList(with: updatedParks)
        } catch {
            SWAlert.shared.presentDefaultUIKit(message: ErrorFilter.message(from: error))
        }
        isLoading = false
    }

    @ViewBuilder
    var rightBarButton: some View {
        if defaults.isAuthorized {
            Button {
                sheetItem = .createNewPark
            } label: {
                Icons.Regular.plus.view
                    .symbolVariant(.circle)
            }
            .opacity(isLoading ? 0 : 1)
            .disabled(!isNetworkConnected || !viewModel.locationErrorMessage.isEmpty)
        }
    }

    @ViewBuilder
    func makeContentView(for item: SheetItem) -> some View {
        switch item {
        case .filters:
            ParkFilterScreen(filter: $filter)
        case .createNewPark:
            ContentInSheet(title: "Новая площадка", spacing: 0) {
                ParkFormScreen(
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
        case let .parkDetails(park):
            NavigationView {
                ParkDetailScreen(park: park) { deletePark(id: $0) }
            }
        }
    }
}

#if DEBUG
#Preview {
    ParksMapScreen()
        .environmentObject(DefaultsService())
        .environmentObject(ParksManager())
}
#endif
