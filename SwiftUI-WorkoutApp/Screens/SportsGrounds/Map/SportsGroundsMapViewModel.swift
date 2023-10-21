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
    @Published private(set) var locationErrorMessage = ""
    @Published private(set) var addressString = ""
    @Published private(set) var region = MKCoordinateRegion()
    @Published private(set) var ignoreUserLocation = false
    /// Идентификатор страны пользователя
    private var userCountryID = 0
    /// Идентификатор города пользователя
    private var userCityID = 0

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
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
                guard let self, let target = places?.first else { return }
                let street = target.thoroughfare.valueOrEmpty
                if let house = target.subThoroughfare {
                    addressString = street + " " + house
                } else {
                    addressString = street
                }
            }
            region = .init(
                center: location.coordinate,
                span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
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
        }
    }

    func locationManager(_: CLLocationManager, didFailWithError _: Error) {
        if !ignoreUserLocation, !isRegionSet {
            setupDefaultLocation(permissionDenied: false)
        }
    }
}

private extension SportsGroundsMapViewModel {
    func setupDefaultLocation(permissionDenied: Bool) {
        locationErrorMessage = permissionDenied
            ? Constants.Alert.locationPermissionDenied
            : Constants.Alert.needLocationPermission
        let coordinates = ShortAddressService(userCountryID, userCityID).coordinates
        guard coordinates != (.zero, .zero) else {
            ignoreUserLocation = true
            return
        }
        region = .init(
            center: .init(latitude: coordinates.0, longitude: coordinates.1),
            span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
}
