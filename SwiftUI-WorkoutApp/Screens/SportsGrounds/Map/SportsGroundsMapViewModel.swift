import Combine
import DateFormatterService
import MapKit.MKGeometry
import ShortAddressService

@MainActor
final class SportsGroundsMapViewModel: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    private let urlOpener: URLOpener = URLOpenerImp()
    private var filterCancellable: AnyCancellable?
    private var locationErrorCancellable: AnyCancellable?
    private var userCountryID = Int.zero
    private var userCityID = Int.zero
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

    func makeGrounds(refresh: Bool, with defaults: DefaultsProtocol) async {
        if isLoading || !defaultList.isEmpty, !refresh { return }
        if defaultList.isEmpty {
            fillDefaultList()
            applyFilter(with: defaults.mainUserInfo)
            return
        }
        isLoading.toggle()
        do {
            defaultList = try await APIService(with: defaults, needAuth: false).getAllSportsGrounds()
        } catch {
            fillDefaultList()
            errorMessage = ErrorFilterService.message(from: error)
        }
        applyFilter(with: defaults.mainUserInfo)
        isLoading.toggle()
    }

    func checkForRecentUpdates(with defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            let updatedGrounds = try await APIService(with: defaults, needAuth: false).getUpdatedSportsGrounds(
                from: DateFormatterService.halfMinuteAgoDateString
            )
            updatedGrounds.forEach { ground in
                if !defaultList.contains(ground) {
                    defaultList.append(ground)
                } else if let index = sportsGrounds.firstIndex(where: { $0.id == ground.id }) {
                    defaultList[index] = ground
                }
            }
            applyFilter(with: defaults.mainUserInfo)
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func deleteSportsGroundFromList(with groundID: Int) {
        sportsGrounds.removeAll(where: { $0.id == groundID })
        needUpdateAnnotations.toggle()
    }

    func updateFilter(with defaults: DefaultsProtocol) {
        userCountryID = defaults.mainUserCountryID
        userCityID = defaults.mainUserCityID
        filter.onlyMyCity = defaults.isAuthorized
    }

    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            urlOpener.open(url)
        }
    }

    func onAppearAction() { manager.startUpdatingLocation() }

    func onDisappearAction() { manager.stopUpdatingLocation() }

    func clearErrorMessage() { errorMessage = "" }
}

extension SportsGroundsMapViewModel {
    var isRegionSet: Bool {
        region.center.latitude != .zero
        && region.center.longitude != .zero
    }
}

extension SportsGroundsMapViewModel: CLLocationManagerDelegate {
    func locationManager(
        _: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.last {
            CLGeocoder().reverseGeocodeLocation(location) { [weak self] places, _ in
                if let target = places?.first {
                    self?.filter.currentCity = target.locality
                    self?.addressString = target.thoroughfare.valueOrEmpty
                    + " " + target.subThoroughfare.valueOrEmpty
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
