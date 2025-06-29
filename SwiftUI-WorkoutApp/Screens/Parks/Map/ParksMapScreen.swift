import ClusteringMapView
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

    /// Отфильтрованные по выбранному городу и активным фильтрам площадки
    private var filteredParks: [Park] {
        let regularParks = parksManager.fullList.filter { park in
            defaults.parksFilter.size.map(\.rawValue).contains(park.sizeId)
                && defaults.parksFilter.grade.map(\.rawValue).contains(park.typeId)
        }
        return if let selectedCity = viewModel.selectedCity {
            regularParks.filter { $0.cityId == Int(selectedCity.id) }
        } else {
            regularParks
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                segmentedControl
                searchCityButton
                parksContent
                    .overlay { noParksFoundView }
            }
            .loadingOverlay(if: isLoading || viewModel.newParkState.isProcessingNewPark)
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
            .navigationTitle("Площадки (\(filteredParks.count))")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
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
        if let storedCities = try? SWAddress.cities() {
            SWTextFieldSearchButton(
                .init(viewModel.cityFilterButtonTitle),
                showClearButton: viewModel.canClearCityFilter,
                mainAction: { sheetItem = .searchCity(storedCities) },
                clearAction: { viewModel.updateSelectedCity(nil) }
            )
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    var parksContent: some View {
        switch presentation {
        case .list:
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredParks) { park in
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
                .padding([.horizontal, .bottom])
            }
        case .map:
            ClusteringMapView(
                region: viewModel.region,
                shouldUpdateRegion: viewModel.shouldUpdateRegion,
                onRegionUpdated: viewModel.resetRegionUpdateFlag,
                hideTrackingButton: viewModel.ignoreUserLocation,
                annotations: filteredParks.map(\.annotation),
                didSelect: { annotation in
                    if let park = filteredParks.first(
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
        if let storedCities = try? SWAddress.cities() {
            NoParksFoundView(
                openCities: { sheetItem = .searchCity(storedCities) },
                openFilter: { sheetItem = .filters },
                model: .init(
                    isFilterEdited: defaults.parksFilter.isEdited,
                    isFilteredParksEmpty: filteredParks.isEmpty,
                    didParksManagerLoad: parksManager.didLoad,
                    isLoading: isLoading
                )
            )
        }
    }

    /// Заполняем/обновляем дефолтный список площадок
    func askForParks(refresh: Bool = false) async {
        if !filteredParks.isEmpty, !refresh { return }
        guard !parksManager.fullList.isEmpty else {
            // Заполняем дефолтный список площадок контентом из `json`-файла
            do {
                try parksManager.makeDefaultList()
            } catch {
                SWAlert.shared.presentDefaultUIKit(error)
            }
            // Если прошло больше одного дня с момента предыдущего обновления, делаем обновление
            if parksManager.needUpdateDefaultList {
                await askForParks(refresh: true)
            }
            return
        }
        await getUpdatedParks()
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
        isLoading = true
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
            NavigationView {
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
            .navigationViewStyle(.stack)
        case let .parkDetails(park):
            NavigationView {
                ParkDetailScreen(
                    park: park,
                    onEdit: updatePark,
                    onDelete: deletePark
                )
            }
            .navigationViewStyle(.stack)
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
}

#if DEBUG
#Preview {
    ParksMapScreen()
        .environmentObject(DefaultsService())
        .environmentObject(ParksManager())
}
#endif
