import MapKit.MKGeometry

final class SportsGroundsMapViewModel: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    @Published var list = Bundle.main.decodeJson(
        [SportsGround].self,
        fileName: "oldSportsGrounds.json"
    )
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published var openDetails = false
    @Published var selectedGround = SportsGround.emptyValue
    @Published var addressString = ""
    @Published var region = MKCoordinateRegion()

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    @MainActor
    func makeGrounds(refresh: Bool) async {
        if (isLoading || !list.isEmpty) && !refresh { return }
        isLoading.toggle()
        do {
            list = try await APIService().getAllSportsGrounds()
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
            let dateString = FormatterService.isoStringFromFullDate(Constants.fiveMinutesAgo)
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

    func onAppearAction() {
        manager.stopUpdatingLocation()
    }

    func onDisappearAction() {
        manager.startUpdatingLocation()
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
#if DEBUG
            print("--- Запрещен доступ к геолокации")
#endif
        case .denied:
#if DEBUG
            print("--- Отклонен запрос на доступ к геолокации")
#endif
        @unknown default: break
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
#if DEBUG
        print("--- LocationManager столкнулся с ошибкой: \(error.localizedDescription)")
#endif
    }
}
