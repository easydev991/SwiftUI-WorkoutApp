import ClusteringMapView
import MapKit
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран с картой и площадками
struct ParksMapScreen: View {
    @EnvironmentObject private var defaults: DefaultsService
    @EnvironmentObject private var parksManager: ParksManager
    @StateObject private var viewModel = ViewModel()
    @State private var presentation = Presentation.map
    @State private var isLoading = false
    @State private var sheetItem: SheetItem?

    // MARK: - Кэшированные данные для оптимизации производительности
    @State private var cachedFilteredParks: [Park] = []
    @State private var cachedFilteredParksCount = 0
    @State private var cachedAnnotations: [any MKAnnotation] = []
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
            .navigationTitle("Площадки (\(cachedFilteredParksCount))")
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
            sheetItem = .filters
        } label: {
            Icons.Regular.filter.view
                .symbolVariant(defaults.parksFilter.isEdited ? .fill : .none)
        }
    }

    var refreshButton: some View {
        Button {
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
                mainAction: { sheetItem = .searchCity(cachedCities) },
                clearAction: { viewModel.updateSelectedCity(nil) }
            )
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    var parksContent: some View {
        switch presentation {
        case .list:
            List(cachedFilteredParks) { park in
                ParkRowItemView(
                    imageURL: park.previewImageURL,
                    title: park.longTitle,
                    address: park.address,
                    usersTrainHereText: park.usersTrainHereText,
                    action: { sheetItem = .parkDetails(park) }
                )
            }
            .listStyle(.plain)
            .padding(.bottom)
        case .map:
            ClusteringMapView(
                region: viewModel.region,
                shouldUpdateRegion: viewModel.shouldUpdateRegion,
                onRegionUpdated: viewModel.resetRegionUpdateFlag,
                hideTrackingButton: viewModel.ignoreUserLocation,
                annotations: cachedAnnotations,
                didSelect: { annotation in
                    if let park = cachedFilteredParks.first(
                        where: { $0.annotation.title == annotation.title }
                    ) {
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
        }
    }

    @ViewBuilder
    var noParksFoundView: some View {
        if let storedCities = cachedCities {
            NoParksFoundView(
                openCities: { sheetItem = .searchCity(storedCities) },
                openFilter: { sheetItem = .filters },
                model: .init(
                    isFilterEdited: defaults.parksFilter.isEdited,
                    isFilteredParksEmpty: cachedFilteredParks.isEmpty,
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
            try? SWAddress.cities()
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
        if !cachedFilteredParks.isEmpty, !refresh { return }
        guard parksManager.fullList.isEmpty else {
            updateFilteredParks()
            return
        }
        do {
            try await parksManager.makeDefaultList()
            updateFilteredParks()
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
        }
        if parksManager.needUpdateDefaultList {
            await askForParks(refresh: true)
        }
    }

    func deletePark(id: Int) {
        sheetItem = nil
        do {
            try parksManager.deletePark(with: id)
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
        }
    }

    func updatePark(_ park: Park) {
        do {
            try parksManager.manuallyUpdatePark(park)
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
        }
    }

    /// Проверяем недавние обновления списка площадок
    ///
    /// Запрашиваем обновление за прошедшие 5 минут
    func checkForRecentUpdates() async {
        defaults.setUserNeedUpdate(true)
        await getUpdatedParks(from: DateFormatterService.fiveMinutesAgoDateString)
    }

    func getUpdatedParks(from dateString: String? = nil) async {
        do {
            try await parksManager.getUpdatedParks(with: defaults, from: dateString)
        } catch ClientError.noConnection {
            SWAlert.shared.presentNoConnection(false)
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
        }
        isLoading = false
    }

    @ViewBuilder
    var rightBarButton: some View {
        if defaults.isAuthorized {
            Button(action: viewModel.requestLocationForNewPark) {
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
            ContentInSheet(title: "Новая площадка", spacing: 0) {
                ParkFormScreen(
                    .createNew(model),
                    refreshClbk: {
                        Task {
                            await checkForRecentUpdates()
                        }
                    }
                )
            }
            .environment(\.updateGeocodingCache, viewModel.updateGeocodingCache)
        case let .searchCity(storedCities):
            NavigationStack {
                ItemListScreen(
                    mode: .city,
                    allItems: storedCities.map(\.name),
                    selectedItem: viewModel.selectedCity?.name ?? "",
                    didSelectItem: { cityName in
                        let newCity = storedCities.first(where: { $0.name == cityName })
                        viewModel.updateSelectedCity(newCity)
                    },
                    didTapContactUs: sendFeedback
                )
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
        let allowedSizeIds = Set(defaults.parksFilter.size.map(\.rawValue))
        let allowedTypeIds = Set(defaults.parksFilter.grade.map(\.rawValue))
        let regularParks = parksManager.fullList.filter { park in
            allowedSizeIds.contains(park.sizeId) && allowedTypeIds.contains(park.typeId)
        }
        let filtered: [Park]
        if let selectedCity = viewModel.selectedCity {
            let cityId = Int(selectedCity.id)
            filtered = regularParks.filter { $0.cityId == cityId }
        } else {
            filtered = regularParks
        }
        // Обновляем кэш только если данные изменились
        let newIdentifiers = Set(filtered.map(\.id))
        let oldIdentifiers = Set(cachedFilteredParks.map(\.id))
        if newIdentifiers != oldIdentifiers || cachedFilteredParks.count != filtered.count {
            cachedFilteredParks = filtered
            cachedFilteredParksCount = filtered.count
            updateAnnotations()
        }
    }

    /// Обновляет кэшированные аннотации из отфильтрованных площадок
    /// Создание аннотаций выполняется в фоновом потоке для больших списков
    private func updateAnnotations() {
        let parks = cachedFilteredParks
        // Отменяем предыдущую задачу, если она еще выполняется
        annotationsTask?.cancel()
        // Для больших списков создаем аннотации в фоновом потоке, чтобы не блокировать UI
        annotationsTask = Task.detached(priority: .userInitiated) { [parks] in
            let newAnnotations = parks.map(\.annotation)
            guard !Task.isCancelled else { return }
            let newIdentifiers = Set(newAnnotations.compactMap(\.title))
            // Обновляем кэш на главном потоке
            await MainActor.run {
                guard !Task.isCancelled else { return }

                let oldIdentifiers = Set(self.cachedAnnotations.compactMap(\.title))
                if newIdentifiers != oldIdentifiers || self.cachedAnnotations.count != newAnnotations.count {
                    self.cachedAnnotations = newAnnotations
                }
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
