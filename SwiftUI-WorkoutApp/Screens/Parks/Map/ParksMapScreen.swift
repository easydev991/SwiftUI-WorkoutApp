import ClusteringMapView
import MapKit
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран с картой и площадками
struct ParksMapScreen: View {
    @Environment(\.analyticsService) private var analytics
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @EnvironmentObject private var parksManager: ParksManager
    @StateObject private var viewModel = ViewModel()
    @State private var presentation = Presentation.map
    @State private var isLoading = false
    @State private var sheetItem: SheetItem?

    // MARK: - Кэшированные данные для оптимизации производительности
    @StateObject private var parksCache = ParksCacheManager()
    @StateObject private var annotationsCache = AnnotationsCacheManager()
    @State private var cachedCities: [City]?
    @State private var annotationsTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                segmentedControl
                searchCityButton
                parksContent
                    .overlay { noParksFoundView }
            }
            .loadingOverlay(
                if: isLoading || viewModel.newParkState.isProcessingNewPark
            )
            .background(Color.swBackground)
            .onFirstAppear {
                viewModel.userCityDidChange(defaults.mainUserInfo)
            }
            .onChange(of: sheetItem) { [oldItem = sheetItem] newValue in
                if case .createNewPark = oldItem, newValue == nil {
                    viewModel.finishCreatingNewPark()
                }
            }
            .onChange(of: defaults.mainUserCityId) { _ in
                viewModel.userCityDidChange(defaults.mainUserInfo)
            }
            .onChange(of: viewModel.newParkState) { newState in
                if case let .ready(model) = newState {
                    sheetItem = .createNewPark(model)
                }
            }
            .onChange(of: parksManager.fullList) { _ in
                updateFilteredParks()
            }
            .onChange(of: defaults.parksFilter) { _ in
                updateFilteredParks()
            }
            .onChange(of: viewModel.selectedCity) { _ in
                updateFilteredParks()
            }
            .task {
                isLoading = true
                await loadCities()
                await askForParks()
                await waitForAnnotationsTask()
                isLoading = false
            }
            .sheet(item: $sheetItem) { makeContentView(for: $0) }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Group {
                        filterButton
                        refreshButton
                    }
                    .tint(.accent)
                    .disabled(isLoading)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    rightBarButton
                }
            }
            .navigationTitle("Площадки (\(parksCache.count))")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private extension ParksMapScreen {
    enum SheetItem: Identifiable, Equatable {
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
        case createNewPark(NewParkMapModel)
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

    var filterButton: some View {
        Button {
            analytics.log(.userAction(action: .openParksFilter))
            sheetItem = .filters
        } label: {
            Icons.Regular.filter.view
                .symbolVariant(defaults.parksFilter.isEdited ? .fill : .none)
        }
    }

    var refreshButton: some View {
        Button {
            analytics.log(.userAction(action: .refreshParks))
            Task {
                isLoading = true
                await askForParks(refresh: true)
                await waitForAnnotationsTask()
                isLoading = false
            }
        } label: {
            Icons.Regular.refresh.view
        }
        .disabled(parksManager.isLoading || isLoading)
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
    var searchCityButton: some View {
        if let cachedCities {
            SWTextFieldSearchButton(
                .init(viewModel.cityFilterButtonTitle),
                showClearButton: viewModel.canClearCityFilter,
                mainAction: {
                    analytics.log(.userAction(action: .openCitySearch))
                    sheetItem = .searchCity(cachedCities)
                },
                clearAction: {
                    analytics.log(.userAction(action: .clearCityFilter))
                    viewModel.updateSelectedCity(nil)
                }
            )
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    var parksContent: some View {
        switch presentation {
        case .list:
            List(parksCache.parks) { park in
                ParkRowItemView(
                    imageURL: park.previewImageURL,
                    title: park.longTitle,
                    address: park.checkedAddress,
                    usersTrainHereText: park.usersTrainHereText,
                    action: { sheetItem = .parkDetails(park) }
                )
            }
            .listStyle(.plain)
            .trackScreen(.parksMapList)
        case .map:
            ClusteringMapView(
                region: viewModel.region,
                shouldUpdateRegion: viewModel.shouldUpdateRegion,
                onRegionUpdated: viewModel.resetRegionUpdateFlag,
                hideTrackingButton: viewModel.ignoreUserLocation,
                annotations: annotationsCache.annotations,
                didSelect: { annotation in
                    if let park = parksCache.parks.first(
                        where: { $0.annotation.title == annotation.title }
                    ) {
                        analytics.log(.userAction(action: .selectParkAnnotation(parkId: park.id)))
                        sheetItem = .parkDetails(park)
                    }
                }
            )
            .overlay(alignment: .bottom) {
                LocationSettingReminderView(
                    message: viewModel.locationErrorMessage,
                    isHidden: viewModel.locationErrorMessage.isEmpty
                )
            }
            .trackScreen(.parksMap)
        }
    }

    @ViewBuilder
    var noParksFoundView: some View {
        if let storedCities = cachedCities {
            NoParksFoundView(
                openCities: {
                    analytics.log(.userAction(action: .openCitySearchEmptyState))
                    sheetItem = .searchCity(storedCities)
                },
                openFilter: {
                    analytics.log(.userAction(action: .openFilterEmptyState))
                    sheetItem = .filters
                },
                model: .init(
                    isFilterEdited: defaults.parksFilter.isEdited,
                    isFilteredParksEmpty: parksCache.parks.isEmpty,
                    didParksManagerLoad: parksManager.didLoad,
                    isLoading: isLoading
                )
            )
        }
    }

    // MARK: - Загрузка данных

    /// Загружает список городов асинхронно в фоновом потоке
    private func loadCities() async {
        guard cachedCities == nil else { return }
        let cities = await Task.detached(priority: .userInitiated) {
            try? SWAddress.cities().filter(\.hasValidCoordinates)
        }.value
        cachedCities = cities
    }

    /// Ожидает завершения создания аннотаций, если задача запущена
    private func waitForAnnotationsTask() async {
        if let task = annotationsTask {
            await task.value
        }
    }

    /// Заполняем/обновляем дефолтный список площадок
    func askForParks(refresh: Bool = false) async {
        if !parksCache.parks.isEmpty, !refresh {
            return
        }
        // Если refresh и данные уже загружены - загружаем с сервера
        if refresh, !parksManager.fullList.isEmpty {
            guard isNetworkConnected else {
                SWAlert.shared.presentNoConnection(false)
                return
            }
            await getUpdatedParks()
            return
        }
        guard parksManager.fullList.isEmpty else {
            updateFilteredParks()
            return
        }
        // Если данные не загружены - загружаем дефолтный список из локального хранилища
        do {
            try await parksManager.makeDefaultList()
        } catch {
            analytics.log(.appError(kind: .parkLoadFailed, error: error))
            SWAlert.shared.presentDefaultUIKit(error)
        }
        // Если нужно автоматическое обновление - загружаем с сервера
        if parksManager.needUpdateDefaultList {
            await askForParks(refresh: true)
        }
    }

    func deletePark(id: Int) {
        sheetItem = nil
        do {
            try parksManager.deletePark(with: id)
        } catch {
            analytics.log(.appError(kind: .parkDeleteFailed, error: error))
            SWAlert.shared.presentDefaultUIKit(error)
        }
    }

    func updatePark(_ park: Park) {
        do {
            try parksManager.manuallyUpdatePark(park)
        } catch {
            analytics.log(.appError(kind: .parkSaveFailed, error: error))
            SWAlert.shared.presentDefaultUIKit(error)
        }
    }

    func getUpdatedParks() async {
        do {
            try await parksManager.getUpdatedParks()
        } catch ClientError.noConnection {
            SWAlert.shared.presentNoConnection(false)
        } catch {
            analytics.log(.appError(kind: .parkLoadFailed, error: error))
            SWAlert.shared.presentDefaultUIKit(error)
        }
        isLoading = false
    }

    @ViewBuilder
    var rightBarButton: some View {
        if defaults.isAuthorized {
            Button {
                analytics.log(.userAction(action: .createPark))
                viewModel.requestLocationForNewPark()
            } label: {
                Icons.Regular.plus.view
                    .symbolVariant(.circle)
            }
            .disabled(!viewModel.canCreateNewPark || isLoading)
            .tint(.accent)
        }
    }

    @ViewBuilder
    func makeContentView(for item: SheetItem) -> some View {
        switch item {
        case .filters:
            ParkFilterScreen(filter: $defaults.parksFilter)
        case let .createNewPark(model):
            NavigationStack {
                ParkFormScreen(.createNew(model), refreshClbk: updatePark)
                    .environment(\.updateGeocodingCache, viewModel.updateGeocodingCache)
            }
        case let .searchCity(storedCities):
            NavigationStack {
                ItemListScreen(
                    mode: .city,
                    allItems: storedCities.map(\.name),
                    selectedItem: viewModel.selectedCity?.name ?? "",
                    didSelectItem: { cityName in
                        let newCity = storedCities.first(where: { $0.name == cityName })
                        viewModel.updateSelectedCity(newCity)
                        if let city = newCity {
                            analytics.log(.userAction(action: .selectParkFilterCity(cityId: "\(city.id)")))
                        }
                    },
                    didTapContactUs: sendFeedback
                )
                .trackScreen(.cityList, source: .parksMap)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        CloseButton(mode: .xmark) { sheetItem = nil }
                    }
                }
            }
        case let .parkDetails(park):
            NavigationStack {
                ParkDetailScreen(
                    park: park,
                    onEdit: updatePark,
                    onDelete: deletePark
                )
            }
        }
    }

    func sendFeedback(mode: ItemListScreen.Mode) {
        analytics.log(.userAction(action: .sendFeedback(source: .parksMap)))
        let (subject, body) = switch mode {
        case .city: (LocationFeedback.city.subject, LocationFeedback.city.body)
        case .country: (LocationFeedback.country.subject, LocationFeedback.country.body)
        }
        FeedbackSender.sendFeedback(
            subject: subject,
            messageBody: body,
            recipients: Constants.feedbackRecipient
        )
    }

    // MARK: - Обновление кэша

    /// Обновляет кэшированные отфильтрованные площадки и аннотации
    private func updateFilteredParks() {
        let cityId = viewModel.selectedCity.flatMap { Int($0.id) }
        if parksCache.updateIfNeeded(
            allParks: parksManager.fullList,
            filter: defaults.parksFilter,
            selectedCityId: cityId
        ) {
            updateAnnotations()
        }
    }

    /// Обновляет кэшированные аннотации из отфильтрованных площадок
    /// Создание аннотаций выполняется в фоновом потоке для больших списков
    private func updateAnnotations() {
        let parks = parksCache.parks
        // Отменяем предыдущую задачу, если она еще выполняется
        annotationsTask?.cancel()
        // Для больших списков создаем аннотации в фоновом потоке, чтобы не блокировать UI
        annotationsTask = Task.detached(priority: .userInitiated) { [parks] in
            let newAnnotations = parks.map(\.annotation)
            guard !Task.isCancelled else { return }
            // Обновляем кэш на главном потоке
            await MainActor.run {
                guard !Task.isCancelled else { return }
                annotationsCache.updateIfNeeded(with: newAnnotations)
            }
        }
    }
}

#if DEBUG
#Preview {
    let authHelper = MockAuthHelper()
    ParksMapScreen()
        .environmentObject(DefaultsService(authHelper: authHelper))
        .environmentObject(ParksManager(isUITest: true, authHelper: authHelper))
        .environment(\.isNetworkConnected, true)
}
#endif
