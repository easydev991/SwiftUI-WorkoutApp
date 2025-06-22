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
            category: "ParksMapScreenViewModel"
        )
        /// `true` - таймер отслеживания локации актиуен,  `false` - неактивен
        ///
        /// Местоположение пользователя отслеживается каждые 10 секунд по таймеру,
        /// чтобы снизить нагрузку на аккумулятор
        private var isLocationTrackingActive = false
        private let locationTrackingInterval: TimeInterval = 10
        /// Крайняя локация пользователя, которую мы определили и сохранили в этом сеансе
        private var lastUserLocation: CLLocation?
        private let defaultCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        private var userCoordinateCancellable: AnyCancellable?
        private var locationTrackingCancellable: AnyCancellable?
        private var appLifecycleCancellables = Set<AnyCancellable>()
        /// Менеджер локации
        private let manager = CLLocationManager()
        @Published private(set) var locationErrorMessage = ""
        /// Модель с данными для создания новой площадки
        @Published private(set) var newParkMapModel = NewParkMapModel.empty
        /// Можно ли создавать новую площадку
        var canCreateNewPark: Bool {
            locationErrorMessage.isEmpty && !newParkMapModel.isEmpty
        }

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
        /// Влияет на доступность кнопки отслеживания локации на карте
        @Published private(set) var ignoreUserLocation = false
        /// Координаты города в профиле авторизованного пользователя
        @Published private var userCoordinate: (Double, Double) = (0, 0)

        override init() {
            super.init()
            manager.delegate = self
            manager.requestWhenInUseAuthorization()
            subscribeToUserCoordinate()
            setupAppLifecycleObservers()
            updateSelectedCity(selectedCity)
        }

        /// Обрабатывает изменение данных пользователя
        ///
        /// - Вызывается для настройки `userCoordinate` (для региона без выбранного города) и `cityId` (для новой площадки).
        /// - При изменении любого `Published`-свойства вьюмодели происходит перерисовка карты,
        /// в том числе может обновиться регион - нам это не нужно, поэтому закрываем все обновления
        /// свойств вьюмодели явными проверками на отличия от старых значений
        /// - Parameter info: Данные профиля пользователя
        func userCityDidChange(_ info: UserResponse?) {
            guard let countryId = info?.countryId, let cityId = info?.cityId,
                  let newCoordinate = SWAddress(countryId, cityId).coordinate
            else {
                if userCoordinate != (0, 0) {
                    userCoordinate = (0, 0)
                    newParkMapModel.cityId = 0
                }
                return
            }
            let newUserCoordinate = (newCoordinate.lat, newCoordinate.lon)
            if userCoordinate != newUserCoordinate {
                userCoordinate = newUserCoordinate
            }
            if newParkMapModel.cityId != cityId {
                // Сохраняем город пользователя для новой площадки на случай,
                // если не получится определить город по локации с помощью CLGeocoder
                newParkMapModel.cityId = cityId
            }
        }

        func updateSelectedCity(_ newCity: City?) {
            selectedCity = newCity
            if let newCity, let coordinate = newCity.coordinate2D {
                region = .init(center: coordinate, span: defaultCoordinateSpan)
                logger.debug("Регион карты обновлен для города \(newCity.name): \(coordinate.latitude), \(coordinate.longitude)")
            } else {
                resetMapRegionTo(userCoordinate)
            }
        }

        /// Включает или выключает вьюмодель для работы
        func setActive(_ active: Bool) {
            guard isLocationTrackingActive != active else {
                logger.info("Предотвратили лишний вызов setActive")
                return
            }
            isLocationTrackingActive = active
            if active {
                startPeriodicLocationUpdates()
            } else {
                stopPeriodicLocationUpdates()
            }
        }
    }
}

extension ParksMapScreen.ViewModel: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinate = location.coordinate
        if !region.isSpecified {
            region = .init(center: coordinate, span: defaultCoordinateSpan)
        }
        if let lastUserLocation, lastUserLocation.distance(from: location) < 5 {
            logger.info("Пропускаем обновление локации - расстояние меньше 5 метров")
            return
        }
        lastUserLocation = location
        logger.debug("Сохраняем новую локацию пользователя")
        let newCoordinate = LocationCoordinate(coordinate)
        let newParkCoordinate = LocationCoordinate(newParkMapModel.coordinate)
        if newCoordinate != newParkCoordinate {
            logger.debug("Сохраняем координаты для newParkMapModel")
            newParkMapModel = .init(
                oldModel: newParkMapModel,
                newLatitude: coordinate.latitude,
                newLongitude: coordinate.longitude
            )
        }
        guard newParkMapModel.address.isEmpty else { return }
        logger.debug("Запускаем CLGeocoder...")
        CLGeocoder().reverseGeocodeLocation(location, preferredLocale: .init(identifier: "ru_RU")) { [weak self] places, error in
            guard let self, let target = places?.first else { return }
            if let error {
                let message = error.localizedDescription
                logger.error("\(message)")
                assertionFailure(message)
            }
            logger.debug("CLGeocoder закончил работу")
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
        if !ignoreUserLocation, !region.isSpecified {
            setupDefaultLocation(permissionDenied: false)
        }
    }
}

private extension ParksMapScreen.ViewModel {
    func subscribeToUserCoordinate() {
        // Реагируем на изменение `userCoordinates`, если город не выбран
        userCoordinateCancellable = $userCoordinate
            .dropFirst()
            .removeDuplicates { old, new in
                old.0 == new.0 && old.1 == new.1
            }
            .filter { [weak self] _ in
                self?.selectedCity == nil
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newCoordinates in
                self?.resetMapRegionTo(newCoordinates)
            }
    }

    /// Подписываемся на события сворачивания/разворачивания приложения,
    /// чтобы включать и выключать отслеживание локации
    func setupAppLifecycleObservers() {
        let center = NotificationCenter.default
        center.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.stopPeriodicLocationUpdates()
            }
            .store(in: &appLifecycleCancellables)
        center.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.startPeriodicLocationUpdates()
            }
            .store(in: &appLifecycleCancellables)
    }

    func setupDefaultLocation(permissionDenied: Bool) {
        locationErrorMessage = permissionDenied
            ? Strings.Alert.locationPermissionDenied
            : Strings.Alert.needLocationPermission
        resetMapRegionTo(userCoordinate)
    }

    func startPeriodicLocationUpdates() {
        guard isLocationTrackingActive else { return }
        logger.info("Запустили таймер для отслеживание локации")
        locationTrackingCancellable = Timer.publish(
            every: locationTrackingInterval,
            on: .main,
            in: .common
        )
        .autoconnect()
        .sink { [weak self] _ in
            guard let self, isLocationTrackingActive else { return }
            logger.debug("Запрашиваем новую локацию")
            manager.requestLocation()
        }
    }

    func stopPeriodicLocationUpdates() {
        logger.info("Остановили отслеживание локации")
        locationTrackingCancellable?.cancel()
        locationTrackingCancellable = nil
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

    /// Сбрасывает регион карты на точку пользователя из профиля
    ///
    /// Предварительно вычисляем широту и долготу при помощи  `SWAddress` на основе справочника стран/городов
    /// - Parameter userCoordinate: Широта и долгота по данным профиля
    func resetMapRegionTo(_ userCoordinate: (Double, Double)) {
        guard userCoordinate != (0, 0) else {
            ignoreUserLocation = true
            if let coordinate2D = City.defaultCity.coordinate2D {
                region = .init(
                    center: coordinate2D,
                    span: defaultCoordinateSpan
                )
                logger.debug("Регион карты сброшен к координатам Москвы (пользователь не авторизовался)")
            }
            return
        }
        region = .init(
            center: .init(latitude: userCoordinate.0, longitude: userCoordinate.1),
            span: defaultCoordinateSpan
        )
        logger.debug("Регион карты сброшен к координатам: \(userCoordinate.0), \(userCoordinate.1)")
        ignoreUserLocation = false
    }
}
