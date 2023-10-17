import Combine
import DateFormatterService
import MapKit.MKGeometry
import ShortAddressService
import SWFileManager
import SWModels
import SWNetworkClient

@MainActor
final class SportsGroundsMapViewModel: NSObject, ObservableObject {
    /// Менеджер локации
    private let manager = CLLocationManager()
    /// Держит обновление фильтра площадок
    private var filterCancellable: AnyCancellable?
    /// Держит обновление ошибки определения геолокации
    private var locationErrorCancellable: AnyCancellable?
    @Published private(set) var locationErrorMessage = ""
    @Published private(set) var addressString = ""
    @Published private(set) var region = MKCoordinateRegion()
    @Published private(set) var ignoreUserLocation = false
    @Published var needUpdateRegion = false
    /// Идентификатор страны пользователя
    private var userCountryID = 0
    /// Идентификатор города пользователя
    private var userCityID = 0

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        self.locationErrorCancellable = $locationErrorMessage
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .sink { [weak self] _ in
                self?.setupDefaultLocation()
            }
    }
    
    func updateUserCountryAndCity(with info: UserResponse?) {
        guard let countryID = info?.countryID, let cityID = info?.cityID else {
            return
        }
        userCountryID = countryID
        userCityID = cityID
    }
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
                    addressString = target.thoroughfare.valueOrEmpty
                    + " "
                    + target.subThoroughfare.valueOrEmpty
                }
            }
            let needUpdateMap = !isRegionSet
            region = .init(
                center: location.coordinate,
                span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            if needUpdateMap { needUpdateRegion = true }
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
        needUpdateRegion = true
    }
}
