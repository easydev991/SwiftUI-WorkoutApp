import ClusteringMapView
import Combine
import MapKit.MKGeometry
import OSLog
import SwiftUI // для использования @AppStorage
import SWModels

extension ParksMapScreen {
    final class ViewModel: NSObject, ObservableObject {
        private let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: ViewModel.self)
        )
        private let defaultCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        private var cancellable: AnyCancellable?
        /// Менеджер локации
        private let manager = CLLocationManager()
        @Published private(set) var locationErrorMessage = ""
        @Published private(set) var addressString = ""
        /// Город для фильтра списка площадок
        @AppStorage("selectedCityFilter") private(set) var selectedCity: City?
        var cityFilterButtonTitle: String {
            if let selectedCity {
                selectedCity.name
            } else {
                NSLocalizedString("Выбери город", comment: "")
            }
        }

        var canClearCityFilter: Bool { selectedCity != nil }
        @Published private(set) var region = MKCoordinateRegion()
        @Published private(set) var ignoreUserLocation = false
        /// Координаты города в профиле авторизованного пользователя
        @Published private var userCoordinates: (Double, Double) = (0, 0)

        override init() {
            super.init()
            manager.delegate = self
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            subscribeToUserCoordinates()
            updateSelectedCity(selectedCity)
        }

        func userInfoDidChange(_ info: UserResponse?) {
            userCoordinates = SWAddress(info?.countryID, info?.cityID)?.coordinates ?? (0, 0)
        }

        func updateSelectedCity(_ newCity: City?) {
            selectedCity = newCity
            if let newCity, let coordinate = newCity.coordinate {
                region = .init(center: coordinate, span: defaultCoordinateSpan)
                logger.debug("Регион карты обновлен для города \(newCity.name): \(coordinate.latitude), \(coordinate.longitude)")
            } else {
                resetTo(userCoordinates)
            }
        }
    }
}

extension ParksMapScreen.ViewModel {
    /// `true` - регион пользователя установлен, `false` - не установлен
    var isRegionSet: Bool {
        region.center.latitude != 0.0 &&
            region.center.longitude != 0.0 &&
            region.span.latitudeDelta > 0.0 &&
            region.span.longitudeDelta > 0.0
    }
}

extension ParksMapScreen.ViewModel: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if !isRegionSet {
            region = .init(center: location.coordinate, span: defaultCoordinateSpan)
        }
        let oldCoordinates = LocationCoordinates(region.center)
        let newCoordinates = LocationCoordinates(location.coordinate)
        guard oldCoordinates.differs(from: newCoordinates) || addressString.isEmpty else { return }
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] places, _ in
            guard let self, let target = places?.first else { return }
            updateAddressIfNeeded(placemark: target)
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
            setupDefaultLocation(permissionDenied: true)
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

private extension ParksMapScreen.ViewModel {
    func subscribeToUserCoordinates() {
        // Реагируем на изменение `userCoordinates`, если город не выбран
        cancellable = $userCoordinates
            .dropFirst()
            .removeDuplicates { old, new in
                old.0 == new.0 && old.1 == new.1
            }
            .filter { [weak self] _ in
                self?.selectedCity == nil
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newCoordinates in
                self?.resetTo(newCoordinates)
            }
    }

    func setupDefaultLocation(permissionDenied: Bool) {
        locationErrorMessage = permissionDenied
            ? Strings.Alert.locationPermissionDenied
            : Strings.Alert.needLocationPermission
        resetTo(userCoordinates)
    }

    /// Обновляет старый адрес, если нужно
    ///
    /// - Новый адрес должен отличаться от старого
    /// - Адрес включает все доступные данные, полученные из `placemark`
    /// - Адрес используется при создании новой площадки
    func updateAddressIfNeeded(placemark: CLPlacemark) {
        let fullAddress: String? = {
            let country = placemark.country
            let countryRegion = placemark.administrativeArea
            let countryRegionInfo = placemark.subAdministrativeArea
            let city = placemark.locality
            let cityDistrict = placemark.subLocality
            let street = placemark.thoroughfare
            let houseNumber = placemark.subThoroughfare
            let fullAddress = [country, countryRegion, countryRegionInfo, city, cityDistrict, street, houseNumber]
                .compactMap(\.self)
                .joined(separator: ", ")
            return fullAddress.isEmpty ? nil : fullAddress
        }()
        if let fullAddress, fullAddress != addressString {
            addressString = fullAddress
            logger.debug("Местоположение пользователя: \(fullAddress)")
        }
    }

    func resetTo(_ userCoordinates: (Double, Double)) {
        guard userCoordinates != (0, 0) else {
            ignoreUserLocation = true
            return
        }
        region = .init(
            center: .init(latitude: userCoordinates.0, longitude: userCoordinates.1),
            span: defaultCoordinateSpan
        )
        logger.debug("Регион карты сброшен к координатам пользователя из профиля: \(userCoordinates.0), \(userCoordinates.1)")
    }
}
