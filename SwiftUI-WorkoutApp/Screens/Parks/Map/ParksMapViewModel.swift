import MapKit.MKGeometry
import MapView991
import OSLog
import SWModels
import SWNetworkClient
import Utils

final class ParksMapViewModel: NSObject, ObservableObject {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ParksMapViewModel.self)
    )
    /// Менеджер локации
    private let manager = CLLocationManager()
    @Published private(set) var locationErrorMessage = ""
    @Published private(set) var addressString = ""
    @Published private(set) var region = MKCoordinateRegion()
    @Published private(set) var ignoreUserLocation = false
    /// Координаты города в профиле авторизованного пользователя
    private var userCoordinates: (Double, Double) = (0, 0)

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func updateUserCountryAndCity(with info: UserResponse?) {
        userCoordinates = SWAddress(info?.countryID, info?.cityID)?.coordinates ?? (0, 0)
    }
}

extension ParksMapViewModel {
    /// `true` - регион пользователя установлен, `false` - не установлен
    var isRegionSet: Bool {
        region.center.latitude != .zero && region.center.longitude != .zero
    }

    /// `true` - прячем карту, `false` - не прячем
    var shouldHideMap: Bool {
        !isRegionSet && ignoreUserLocation
    }
}

extension ParksMapViewModel: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if !isRegionSet {
            region = .init(
                center: location.coordinate,
                span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
        let oldCoordinates = LocationCoordinates(region.center)
        let newCoordinates = LocationCoordinates(location.coordinate)
        guard oldCoordinates.differs(from: newCoordinates) || addressString.isEmpty else { return }
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] places, _ in
            guard let self, let target = places?.first else { return }
            SWAddress.updateIfNeeded(&addressString, placemark: target)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationErrorMessage = ""
            ignoreUserLocation = false
            manager.requestLocation()
        case .restricted, .denied:
            if !ignoreUserLocation {
                setupDefaultLocation(permissionDenied: true)
            }
        @unknown default:
            let message = "Не обработан новый кейс `authorizationStatus`"
            logger.error("\(message, privacy: .public)")
            assertionFailure(message)
        }
    }

    func locationManager(_: CLLocationManager, didFailWithError _: Error) {
        if !ignoreUserLocation, !isRegionSet {
            setupDefaultLocation(permissionDenied: false)
        }
    }
}

private extension ParksMapViewModel {
    func setupDefaultLocation(permissionDenied: Bool) {
        locationErrorMessage = permissionDenied
            ? Constants.Alert.locationPermissionDenied
            : Constants.Alert.needLocationPermission
        guard userCoordinates != (0, 0) else {
            ignoreUserLocation = true
            return
        }
        region = .init(
            center: .init(latitude: userCoordinates.0, longitude: userCoordinates.1),
            span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
}
