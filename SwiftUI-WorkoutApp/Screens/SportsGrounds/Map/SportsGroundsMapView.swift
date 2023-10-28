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
    @StateObject private var viewModel = SportsGroundsMapViewModel()
    @State private var presentation = Presentation.map
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var showFilters = false
    @State private var showDetailsView = false
    @State private var showGroundCreationSheet = false
    @State private var selectedGround = SportsGround.emptyValue
    @State private var filter = SportsGroundFilterView.Model()
    @State private var allSportsGrounds = [SportsGround]()
    private var filteredGrounds: [SportsGround] {
        allSportsGrounds.filter { ground in
            filter.size.map(\.code).contains(ground.sizeID)
                && filter.grade.map(\.code).contains(ground.typeID)
        }
    }

    /// Хранилище файла с площадками
    private let swStorage = FileManager991(fileName: "SportsGrounds.json")

    var body: some View {
        NavigationView {
            VStack {
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
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Group {
                        filterButton
                        Button {
                            Task { await askForGrounds(refresh: true) }
                        } label: {
                            Image(systemName: Icons.Regular.refresh.rawValue)
                        }
                    }
                    .disabled(isLoading)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    rightBarButton
                }
            }
            .navigationTitle("Площадки (\(filteredGrounds.count))")
            .navigationBarTitleDisplayMode(.inline)
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
            Image(
                systemName: filter.isEdited
                    ? Icons.Regular.filterOn.rawValue
                    : Icons.Regular.filterOff.rawValue
            )
        }
        .sheet(isPresented: $showFilters) {
            SportsGroundFilterView(filter: $filter)
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
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredGrounds) { ground in
                        NavigationLink {
                            SportsGroundDetailView(
                                ground: ground,
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
            MapView991(
                region: viewModel.region,
                hideTrackingButton: viewModel.ignoreUserLocation,
                annotations: filteredGrounds,
                didSelect: { annotation in
                    if let ground = filteredGrounds.first(where: { $0 === annotation }) {
                        selectedGround = ground
                        showDetailsView = true
                    }
                }
            )
            .opacity(viewModel.shouldHideMap ? 0 : 1)
            .overlay(alignment: viewModel.isRegionSet ? .bottom : .center) {
                NavigationLink(isActive: $showDetailsView) {
                    SportsGroundDetailView(
                        ground: selectedGround,
                        onDeletion: updateDeleted
                    )
                } label: { EmptyView() }
                LocationSettingReminderView(
                    message: viewModel.locationErrorMessage,
                    isHidden: !viewModel.ignoreUserLocation
                )
            }
        }
    }

    /// Заполняем/обновляем дефолтный список площадок
    func askForGrounds(refresh: Bool = false) async {
        if !filteredGrounds.isEmpty, !refresh { return }
        guard !allSportsGrounds.isEmpty else {
            // Заполняем дефолтный список площадок контентом из `json`-файла
            do {
                let savedGrounds: [SportsGround] = if swStorage.documentExists {
                    try swStorage.get()
                } else {
                    try Bundle.main.decodeJson(
                        [SportsGround].self,
                        fileName: "oldSportsGrounds",
                        extension: "json"
                    )
                }
                allSportsGrounds = savedGrounds
            } catch {
                setupErrorAlert(error.localizedDescription)
            }
            // Если прошло больше одного дня с момента предыдущего обновления, делаем обновление
            if DateFormatterService.days(from: defaults.lastGroundsUpdateDateString, to: .now) > 1 {
                await askForGrounds(refresh: true)
            }
            return
        }
        isLoading = true
        do {
            let updatedGrounds = try await SWClient(with: defaults, needAuth: false).getUpdatedSportsGrounds(
                from: defaults.lastGroundsUpdateDateString
            )
            updateDefaultList(with: updatedGrounds)
        } catch {
            setupErrorAlert(ErrorFilter.message(from: error))
        }
        isLoading = false
    }

    /// Проверяем недавние обновления списка площадок
    ///
    /// Запрашиваем обновление за прошедшие 5 минут
    func checkForRecentUpdates() async {
        defaults.setUserNeedUpdate(true)
        isLoading = true
        do {
            let updatedGrounds = try await SWClient(with: defaults, needAuth: false).getUpdatedSportsGrounds(
                from: DateFormatterService.fiveMinutesAgoDateString
            )
            updateDefaultList(with: updatedGrounds)
        } catch {
            setupErrorAlert(ErrorFilter.message(from: error))
        }
        isLoading = false
    }

    /// Обновляем дефолтный список площадок
    func updateDefaultList(with updatedGrounds: [SportsGround]) {
        guard !updatedGrounds.isEmpty else { return }
        updatedGrounds.forEach { ground in
            if let index = allSportsGrounds.firstIndex(where: { $0.id == ground.id }) {
                allSportsGrounds[index] = ground
            } else {
                allSportsGrounds.append(ground)
            }
        }
        saveGroundsInMemory()
    }

    /// Сохраняем площадки в памяти
    func saveGroundsInMemory() {
        do {
            try swStorage.save(allSportsGrounds)
            defaults.didUpdateGrounds()
        } catch {
            setupErrorAlert(error.localizedDescription)
        }
    }

    @ViewBuilder
    var rightBarButton: some View {
        if defaults.isAuthorized {
            Button {
                showGroundCreationSheet.toggle()
            } label: {
                Image(systemName: Icons.Regular.plus.rawValue)
            }
            .opacity(isLoading ? 0 : 1)
            .disabled(!network.isConnected || !viewModel.locationErrorMessage.isEmpty)
            .sheet(isPresented: $showGroundCreationSheet) {
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
            }
        }
    }

    /// Удаляет площадку с указанным идентификатором из списка
    ///
    /// Используется при ручном удалении площадки с детального экрана площадки
    func updateDeleted(groundID: Int) {
        allSportsGrounds.removeAll(where: { $0.id == groundID })
        saveGroundsInMemory()
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
}
#endif
