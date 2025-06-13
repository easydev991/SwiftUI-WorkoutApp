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
        /// Модель с данными для создания новой площадки
        @Published private(set) var newParkMapModel = NewParkMapModel.empty
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
        let coordinate = location.coordinate
        if !isRegionSet {
            region = .init(center: coordinate, span: defaultCoordinateSpan)
        }
        let oldCoordinates = LocationCoordinates(region.center)
        let newCoordinates = LocationCoordinates(coordinate)
        let newParkCoordinates = LocationCoordinates(newParkMapModel.coordinate)
        if newCoordinates.differs(from: newParkCoordinates) {
            newParkMapModel.latitude = coordinate.latitude
            newParkMapModel.longitude = coordinate.longitude
        }
        guard oldCoordinates.differs(from: newCoordinates) || newParkMapModel.address.isEmpty else { return }
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] places, error in
            guard let self, let target = places?.first else { return }
            if let error {
                let message = error.localizedDescription
                logger.error("\(message)")
                assertionFailure(message)
            }
            updateAddressIfNeeded(placemark: target)
            updateCityIfNeeded(placemark: target)
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

    /// Обновляет адрес для новой площадки, если нужно
    ///
    /// - Новый адрес должен отличаться от старого
    /// - Адрес включает все доступные данные, полученные из `placemark`
    /// - Parameter placemark: Точка на карте
    func updateAddressIfNeeded(placemark: CLPlacemark) {
        let fullAddress = SWAddress.makeAddress(for: placemark)
        if let fullAddress, fullAddress != newParkMapModel.address {
            newParkMapModel.address = fullAddress
            logger.debug("Адрес для площадки: \(fullAddress)")
        }
    }

    /// Обновляет идентификатор города для новой площадки, если нужно
    ///
    /// Новый идентификатор должен отличаться от старого
    /// - Parameter placemark: Точка на карте
    func updateCityIfNeeded(placemark: CLPlacemark) {
        if let cityId = SWAddress.makeCityId(with: placemark.locality),
           cityId != newParkMapModel.cityId {
            newParkMapModel.cityId = cityId
            logger.debug("Идентификатор города для площадки: \(cityId)")
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
