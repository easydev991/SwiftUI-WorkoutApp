import MapKit.MKGeometry

final class SportsGroundsMapViewModel: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    @Published var filter = SportsGroundFilter() {
        didSet { applyFilter() }
    }
    @Published var list = [SportsGround]()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published var selectedGround = SportsGround.emptyValue
    @Published var addressString = ""
    @Published var region = MKCoordinateRegion()
    private var defaultList = Bundle.main.decodeJson(
        [SportsGround].self,
        fileName: "oldSportsGrounds.json"
    ) {
        didSet { applyFilter() }
    }

    override init() {
        super.init()
        applyFilter()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    @MainActor
    func makeGrounds(refresh: Bool) async {
        if (isLoading || !list.isEmpty) && !refresh { return }
        isLoading.toggle()
        do {
            defaultList = try await APIService().getAllSportsGrounds()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    @MainActor
    func checkForRecentUpdates() async {
        if isLoading { return }
        isLoading.toggle()
        do {
            let dateString = FormatterService.serverFiveMinutesAgo(from: Constants.fiveMinutesAgo)
            let updatedGrounds = try await APIService().getUpdatedSportsGrounds(from: dateString)
            updatedGrounds.forEach { ground in
                if !list.contains(ground) {
                    list.append(ground)
                } else if let index = list.firstIndex(where: { $0.id == ground.id }) {
                    list[index] = ground
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func deleteSportsGroundFromList() {
        list.removeAll(where: { $0.id == selectedGround.id })
    }

    func resetFilter() { applyFilter() }

    func onAppearAction() {
        manager.startUpdatingLocation()
    }

    func onDisappearAction() {
        manager.stopUpdatingLocation()
    }

    func clearErrorMessage() { errorMessage = "" }
}


extension SportsGroundsMapViewModel: CLLocationManagerDelegate {
    @MainActor
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.last {
            region = .init(
                center: location.coordinate,
                span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
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
            manager.requestLocation()
        case .restricted:
            errorMessage = "Запрещен доступ к геолокации"
        case .denied:
            errorMessage = "Для работы карты необходимо разрешить доступ к геолокации в настройках"
        @unknown default: break
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        errorMessage = error.localizedDescription
    }
}

private extension SportsGroundsMapViewModel {
    func applyFilter() {
        let countryID = DefaultsService().mainUserCountry
        let cityID = DefaultsService().mainUserCity
        var result = [SportsGround]()
        result = defaultList.filter { ground in
            filter.size.map { $0.code }.contains(ground.sizeID)
            && filter.type.map { $0.code }.contains(ground.typeID)
        }
        guard countryID != .zero else {
            list = result
            return
        }
        if filter.onlyMyCity {
            result = result.filter {
                $0.countryID == countryID
                && $0.cityID == cityID
            }
        }
        list = result
    }
}
