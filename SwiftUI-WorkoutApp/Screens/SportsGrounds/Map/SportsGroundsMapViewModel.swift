import MapKit.MKGeometry

@MainActor
final class SportsGroundsMapViewModel: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    private var userCountryID = Int.zero
    private var userCityID = Int.zero
    private var defaultList = [SportsGround]()
    var isRegionSet: Bool {
        region.center.latitude != .zero
        && region.center.longitude != .zero
    }
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var locationErrorMessage = ""
    @Published var filter = SportsGroundFilter() {
        didSet { applyFilter(userCountryID, userCityID) }
    }
    @Published var sportsGrounds = [SportsGround]()
    @Published var selectedGround = SportsGround.emptyValue
    @Published var addressString = ""
    @Published var region = MKCoordinateRegion()
    @Published var needUpdateAnnotations = false
    @Published var needUpdateRegion = false
    @Published var ignoreUserLocation = false

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func makeGrounds(refresh: Bool, with defaults: DefaultsService) async {
        if (isLoading || !defaultList.isEmpty) && !refresh { return }
        if defaultList.isEmpty {
            fillDefaultList()
            applyFilter(defaults.mainUserCountry, defaults.mainUserCity)
            return
        }
        isLoading.toggle()
        do {
            defaultList = try await APIService(with: defaults).getAllSportsGrounds()
        } catch {
            fillDefaultList()
            errorMessage = error.localizedDescription
        }
        applyFilter(defaults.mainUserCountry, defaults.mainUserCity)
        isLoading.toggle()
    }

    func checkForRecentUpdates(with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            let updatedGrounds = try await APIService(with: defaults).getUpdatedSportsGrounds(
                from: FormatterService.halfMinuteAgoDateString()
            )
            updatedGrounds.forEach { ground in
                if !defaultList.contains(ground) {
                    defaultList.append(ground)
                } else if let index = sportsGrounds.firstIndex(where: { $0.id == ground.id }) {
                    defaultList[index] = ground
                }
            }
            applyFilter(defaults.mainUserCountry, defaults.mainUserCity)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func deleteSportsGroundFromList() {
        sportsGrounds.removeAll(where: { $0.id == selectedGround.id })
        needUpdateAnnotations.toggle()
    }

    func updateFilter(with defaults: DefaultsService) {
        userCountryID = defaults.mainUserCountry
        userCityID = defaults.mainUserCity
        if !defaults.isAuthorized {
            filter.onlyMyCity = false
        }
        if !locationErrorMessage.isEmpty {
            setupDefaultLocation()
        }
    }

    func onAppearAction() {
        manager.startUpdatingLocation()
    }

    func onDisappearAction() {
        manager.stopUpdatingLocation()
    }

    func clearErrorMessage() { errorMessage = "" }
}

extension SportsGroundsMapViewModel: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.last {
            let needUpdateMap = !isRegionSet
            region = .init(
                center: location.coordinate,
                span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            if needUpdateMap {
                needUpdateRegion.toggle()
            }
            CLGeocoder().reverseGeocodeLocation(location) { [weak self] places, _ in
                if let target = places?.first {
                    self?.addressString = target.thoroughfare.valueOrEmpty
                    + " " + target.subThoroughfare.valueOrEmpty
                }
            }
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
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        if !ignoreUserLocation && !isRegionSet {
            setupDefaultLocation()
        }
        #if DEBUG
        print("--- locationManager didFailWithError: \(error.localizedDescription)")
        #endif
    }
}

private extension SportsGroundsMapViewModel {
    func applyFilter(_ countryID: Int, _ cityID: Int) {
        var result = [SportsGround]()
        result = defaultList.filter { ground in
            filter.size.map { $0.code }.contains(ground.sizeID)
            && filter.type.map { $0.code }.contains(ground.typeID)
        }
        guard countryID != .zero, filter.onlyMyCity else {
            sportsGrounds = result
            needUpdateAnnotations.toggle()
            return
        }
        sportsGrounds = result.filter {
            $0.countryID == countryID
            && $0.cityID == cityID
        }
        needUpdateAnnotations.toggle()
    }

    func fillDefaultList() {
        do {
            let oldGrounds = try Bundle.main.decodeJson(
                [SportsGround].self,
                fileName: "oldSportsGrounds.json"
            )
            defaultList = oldGrounds
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setupDefaultLocation(permissionDenied: Bool = false) {
        ignoreUserLocation = true
        locationErrorMessage = permissionDenied
        ? Constants.Alert.locationPermissionDenied
        : Constants.Alert.needLocationPermission
        let coordinates = ShortAddressService().coordinates(userCountryID, userCityID)
        guard coordinates != (.zero, .zero) else {
            return
        }
        region = .init(
            center: .init(
                latitude: coordinates.0,
                longitude: coordinates.1
            ),
            span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        needUpdateRegion.toggle()
    }
}
