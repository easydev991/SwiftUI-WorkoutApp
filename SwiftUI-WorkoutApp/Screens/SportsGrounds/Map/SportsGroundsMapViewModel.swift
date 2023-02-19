import Combine
import DateFormatterService
import MapKit.MKGeometry
import ShortAddressService

@MainActor
final class SportsGroundsMapViewModel: NSObject, ObservableObject {
    /// Дата предыдущего ручного обновления справочника площадок
    ///
    /// - При обновлении справочника вручную необходимо обновить тут дату
    /// - Неудобно, зато спасаемся от постоянных ошибок 500 на сервере
    private let previousManualUpdateDateString = "2023-01-12T00:00:00"
    /// Менеджер локации
    private let manager = CLLocationManager()
    private let urlOpener: URLOpener = URLOpenerImp()
    /// Держит обновление фильтра площадок
    private var filterCancellable: AnyCancellable?
    /// Держит обновление ошибки определения геолокации
    private var locationErrorCancellable: AnyCancellable?
    /// Идентификатор страны пользователя
    private var userCountryID = Int.zero
    /// Идентификатор города пользователя
    private var userCityID = Int.zero
    /// Дефолтный список площадок, загруженный из `json`-файла
    private var defaultList = [SportsGround]()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var locationErrorMessage = ""
    @Published private(set) var addressString = ""
    @Published private(set) var region = MKCoordinateRegion()
    @Published private(set) var ignoreUserLocation = false
    @Published var needUpdateAnnotations = false
    @Published var needUpdateRegion = false
    @Published var sportsGrounds = [SportsGround]()
    @Published var selectedGround = SportsGround.emptyValue
    @Published var filter = SportsGroundFilterView.Model()

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        self.filterCancellable = $filter
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self else { return }
                self.applyFilter(self.userCountryID, self.userCityID)
            }
        self.locationErrorCancellable = $locationErrorMessage
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .sink { [weak self] _ in
                self?.setupDefaultLocation()
            }
    }

    /// Заполняем/обновляем дефолтный список площадок
    func makeGrounds(refresh: Bool, with defaults: DefaultsProtocol) async {
        if isLoading || !defaultList.isEmpty, !refresh { return }
        if defaultList.isEmpty {
            fillDefaultList()
            applyFilter(with: defaults.mainUserInfo)
            return
        }
        isLoading.toggle()
        do {
            let updatedGrounds = try await APIService(with: defaults, needAuth: false).getUpdatedSportsGrounds(
                from: previousManualUpdateDateString
            )
            updateDefaultList(with: updatedGrounds)
            applyFilter(with: defaults.mainUserInfo)
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    /// Проверяем недавние обновления списка площадок
    ///
    /// Запрашиваем обновление за прошедшие 5 минут
    func checkForRecentUpdates(with defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            let updatedGrounds = try await APIService(with: defaults, needAuth: false).getUpdatedSportsGrounds(
                from: DateFormatterService.fiveMinutesAgoDateString
            )
            updateDefaultList(with: updatedGrounds)
            applyFilter(with: defaults.mainUserInfo)
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    /// Удаляет площадку с указанным идентификатором из списка
    ///
    /// Используется при ручном удалении площадки с детального экрана площадки
    func deleteSportsGroundFromList(with groundID: Int) {
        sportsGrounds.removeAll(where: { $0.id == groundID })
        needUpdateAnnotations.toggle()
    }

    func updateUserCountryAndCity(with info: UserResponse?) {
        guard let countryID = info?.countryID, let cityID = info?.cityID else {
            filter.onlyMyCity = false
            return
        }
        userCountryID = countryID
        userCityID = cityID
    }

    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            urlOpener.open(url)
        }
    }

    /// Запускаем обновление локации пользователя
    func onAppearAction() { manager.startUpdatingLocation() }

    /// Отключаем обновление локации пользователя
    func onDisappearAction() { manager.stopUpdatingLocation() }

    func clearErrorMessage() { errorMessage = "" }
}

extension SportsGroundsMapViewModel {
    /// `true` - регион пользователя установлен, `false` - не установлен
    var isRegionSet: Bool {
        region.center.latitude != .zero && region.center.longitude != .zero
    }

    /// `true` - прячем карту, `false` - не прячем
    var shouldHideMap: Bool {
        !isRegionSet && ignoreUserLocation
    }
}

extension SportsGroundsMapViewModel: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            CLGeocoder().reverseGeocodeLocation(location) { [weak self] places, _ in
                guard let self else { return }
                if let target = places?.first {
                    self.filter.currentCity = target.locality
                    self.addressString = target.thoroughfare.valueOrEmpty
                        + " "
                        + target.subThoroughfare.valueOrEmpty
                }
            }
            let needUpdateMap = !isRegionSet
            region = .init(
                center: location.coordinate,
                span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            if needUpdateMap { needUpdateRegion.toggle() }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationErrorMessage = ""
            ignoreUserLocation = false
            region = .init()
            manager.requestLocation()
        case .restricted:
            if !ignoreUserLocation {
                setupDefaultLocation(permissionDenied: true)
            }
        case .denied:
            if !ignoreUserLocation {
                setupDefaultLocation()
            }
        @unknown default: break
        }
    }

    func locationManager(
        _: CLLocationManager,
        didFailWithError error: Error
    ) {
        if !ignoreUserLocation, !isRegionSet {
            setupDefaultLocation()
        }
        #if DEBUG
        print("--- locationManager didFailWithError: \(error.localizedDescription)")
        #endif
    }
}

private extension SportsGroundsMapViewModel {
    func applyFilter(with userInfo: UserResponse?) {
        applyFilter(userInfo?.countryID, userInfo?.cityID)
    }

    /// Применяем фильтры к `defaultList` и выводим итоговый список в `sportsGrounds`
    func applyFilter(_ countryID: Int?, _ cityID: Int?) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self else { return }
            var result = [SportsGround]()
            result = self.defaultList.filter { ground in
                self.filter.size.map(\.code).contains(ground.sizeID)
                    && self.filter.grade.map(\.code).contains(ground.typeID)
            }
            guard let countryID, countryID != .zero,
                  let cityID, cityID != .zero,
                  self.filter.onlyMyCity
            else {
                DispatchQueue.main.async {
                    self.sportsGrounds = result
                    self.needUpdateAnnotations.toggle()
                }
                return
            }
            DispatchQueue.main.async {
                self.sportsGrounds = result.filter {
                    $0.countryID == countryID
                        && $0.cityID == cityID
                }
                self.needUpdateAnnotations.toggle()
            }
        }
    }

    /// Заполняем дефолтный список площадок контентом из `json`-файла
    func fillDefaultList() {
        do {
            let oldGrounds = try Bundle.main.decodeJson(
                [SportsGround].self,
                fileName: "oldSportsGrounds",
                extension: "json"
            )
            defaultList = oldGrounds
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
    }

    /// Обновляем дефолтный список площадок
    func updateDefaultList(with updatedList: [SportsGround]) {
        updatedList.forEach { ground in
            if let index = defaultList.firstIndex(where: { $0.id == ground.id }) {
                defaultList[index] = ground
            } else {
                defaultList.append(ground)
            }
        }
    }

    func setupDefaultLocation(permissionDenied: Bool = false) {
        ignoreUserLocation = true
        locationErrorMessage = permissionDenied
            ? Constants.Alert.locationPermissionDenied
            : Constants.Alert.needLocationPermission
        let coordinates = ShortAddressService(userCountryID, userCityID).coordinates
        guard coordinates != (.zero, .zero) else { return }
        region = .init(
            center: .init(latitude: coordinates.0, longitude: coordinates.1),
            span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        needUpdateRegion.toggle()
    }
}
