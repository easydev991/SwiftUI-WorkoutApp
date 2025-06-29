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
        /// Подписки, которые должны работать всегда, пока существует вьюмодель
        private var persistentCancellables = Set<AnyCancellable>()

        override init() {
            super.init()
            manager.delegate = self
            manager.requestWhenInUseAuthorization()
            setupUserCityCoordinateObserver()
            setupRegionChangeObserver()
            updateSelectedCity(selectedCity)
        }

        // MARK: - Трекинг локации
        /// Менеджер локации
        private let manager = CLLocationManager()
        /// Крайняя локация пользователя, которую мы определили и сохранили в этом сеансе
        @Published private var lastUserLocation: CLLocation?
        /// Время последнего запроса локации
        private var lastLocationRequestTime: Date?
        /// Влияет на доступность кнопки отслеживания локации на карте
        @Published private(set) var ignoreUserLocation = false
        /// Сообщение об ошибке, связанное с локацией
        @Published private(set) var locationErrorMessage = ""

        // MARK: - Регион карты
        @Published private(set) var region = MKCoordinateRegion()
        /// Предыдущее значение региона для отслеживания изменений
        private var previousRegion: MKCoordinateRegion?
        private let defaultCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)

        /// Нужно ли обновлять регион карты
        ///
        /// Используется для выборочного обновления региона
        /// внутри `ClusteringMapView` в методе `updateUIView`
        @Published private(set) var shouldUpdateRegion = false
        /// Сбрасывает флаг обновления региона
        func resetRegionUpdateFlag() {
            if shouldUpdateRegion {
                logger.debug("Сбрасываем флаг обновления региона")
                shouldUpdateRegion = false
            }
        }

        // MARK: - Город пользователя и выбранный город
        /// Координаты города в профиле авторизованного пользователя
        @Published private var userCityCoordinate = LocationCoordinate.empty

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

        /// Обрабатывает изменение данных пользователя
        ///
        /// - Вызывается для настройки `userCoordinate` (для региона без выбранного города) и `cityId` (для новой площадки).
        /// - Parameter info: Данные профиля пользователя
        func userCityDidChange(_ info: UserResponse?) {
            guard let countryId = info?.countryId, let cityId = info?.cityId,
                  let newCoordinate = SWAddress(countryId, cityId).coordinate
            else {
                userCityCoordinate = .empty
                newParkMapModel = NewParkMapModel(
                    coordinate: newParkMapModel.coordinate,
                    cityId: 0,
                    lastLocationRequestDate: newParkMapModel.lastLocationRequestDate
                )
                return
            }
            userCityCoordinate = .init(
                latitude: newCoordinate.lat,
                longitude: newCoordinate.lon
            )
            // Сохраняем город пользователя для новой площадки как fallback значение
            newParkMapModel = NewParkMapModel(
                coordinate: newParkMapModel.coordinate,
                cityId: cityId,
                lastLocationRequestDate: newParkMapModel.lastLocationRequestDate
            )
        }

        /// Обновляет выбранный город для фильтра площадок
        /// - Parameter newCity: Новый город. Если передать `nil`, сбросит фильтр по городу
        func updateSelectedCity(_ newCity: City?) {
            selectedCity = newCity
            if let newCity, let coordinate = newCity.coordinate2D {
                region = .init(center: coordinate, span: defaultCoordinateSpan)
                logger.debug("Регион карты обновлен для города \(newCity.name): \(coordinate.latitude), \(coordinate.longitude)")
            } else {
                resetMapRegionTo(userCityCoordinate)
            }
        }

        // MARK: - Новая площадка
        /// Модель новой площадки
        @Published private(set) var newParkMapModel = NewParkMapModel.empty

        /// Флаг процесса запроса локации для новой площадки
        @Published private(set) var isRequestingLocationForNewPark = false

        /// Флаг процесса создания новой площадки (включает запрос локации + открытый экран)
        @Published private(set) var isCreatingNewPark = false

        /// Можно ли создавать новую площадку
        var canCreateNewPark: Bool {
            locationErrorMessage.isEmpty && !isRequestingLocationForNewPark
        }

        /// Запрашивает локацию для создания новой площадки
        func requestLocationForNewPark() {
            isRequestingLocationForNewPark = true
            isCreatingNewPark = true

            let now = Date()

            // Используем логику из модели для определения нужности запроса локации
            let shouldRequestLocation = lastUserLocation == nil || newParkMapModel.shouldRequestLocation

            if shouldRequestLocation {
                // Обновляем дату запроса в модели
                newParkMapModel = newParkMapModel.updatingLastLocationRequestDate(now)
                lastLocationRequestTime = now
                manager.requestLocation()
            } else {
                // Если локация актуальная, сразу завершаем процесс
                finishLocationRequestForNewPark()
            }
        }

        /// Завершает процесс запроса локации для новой площадки
        func finishLocationRequestForNewPark() {
            isRequestingLocationForNewPark = false
            logger.debug("Завершили запрос локации для новой площадки")
        }

        /// Завершает процесс создания новой площадки (вызывается при закрытии экрана)
        func finishCreatingNewPark() {
            isCreatingNewPark = false
            logger.debug("Завершили создание новой площадки")
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension ParksMapScreen.ViewModel: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinate = location.coordinate
        if !region.isSpecified {
            region = .init(center: coordinate, span: defaultCoordinateSpan)
        }
        logger.debug("Сохраняем новую локацию пользователя")
        lastUserLocation = location
        let newCoordinate = LocationCoordinate(coordinate)
        let currentParkCoordinate = LocationCoordinate(newParkMapModel.coordinate)
        if newCoordinate != currentParkCoordinate {
            logger.debug("Сохраняем координаты для newParkMapModel")
            newParkMapModel = .init(
                oldModel: newParkMapModel,
                newLatitude: coordinate.latitude,
                newLongitude: coordinate.longitude
            )
        }
        // Завершаем процесс запроса локации для новой площадки, если он активен
        if isRequestingLocationForNewPark {
            finishLocationRequestForNewPark()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationErrorMessage = ""
            ignoreUserLocation = false
            lastLocationRequestTime = Date()
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

// MARK: - Подписки Combine
private extension ParksMapScreen.ViewModel {
    /// Отслеживаем изменения региона для управления флагом `shouldUpdateRegion`
    func setupRegionChangeObserver() {
        $region
            .dropFirst()
            .removeDuplicates { old, new in
                LocationCoordinate(old) == LocationCoordinate(new)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newRegion in
                guard let self else { return }
                if newRegion.isSpecified {
                    logger.debug("Регион изменился программно, устанавливаем флаг обновления")
                    shouldUpdateRegion = true
                }
            }
            .store(in: &persistentCancellables)
    }

    /// Реагируем на изменение `userCityCoordinates`, если город не выбран
    func setupUserCityCoordinateObserver() {
        $userCityCoordinate
            .dropFirst()
            .removeDuplicates()
            .filter { [weak self] _ in
                self?.selectedCity == nil
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newCoordinates in
                guard let self else { return }
                resetMapRegionTo(newCoordinates)
            }
            .store(in: &persistentCancellables)
    }
}

// MARK: - Работа с регионом
private extension ParksMapScreen.ViewModel {
    func setupDefaultLocation(permissionDenied: Bool) {
        locationErrorMessage = permissionDenied
            ? Strings.Alert.locationPermissionDenied
            : Strings.Alert.needLocationPermission
        resetMapRegionTo(userCityCoordinate)
    }

    /// Сбрасывает регион карты на точку пользователя из профиля
    ///
    /// Предварительно вычисляем широту и долготу при помощи `SWAddress` на основе справочника стран/городов.
    /// - Parameter userCoordinate: Широта и долгота по данным профиля
    func resetMapRegionTo(_ userCoordinate: LocationCoordinate) {
        guard userCoordinate.isSpecified else {
            let newCenter: CLLocationCoordinate2D? = if let lastUserLocation {
                lastUserLocation.coordinate
            } else if let defaultLocation = City.defaultCity.coordinate2D {
                defaultLocation
            } else {
                nil
            }
            if let newCenter {
                region = .init(center: newCenter, span: defaultCoordinateSpan)
                logger.debug("Регион карты сброшен, пользователь не авторизовался: \(newCenter.latitude), \(newCenter.longitude)")
            }
            return
        }
        region = .init(
            center: userCoordinate.coordinate,
            span: defaultCoordinateSpan
        )
        logger.debug("Регион карты сброшен на координаты: \(userCoordinate.lat), \(userCoordinate.lon)")
        ignoreUserLocation = false
    }
}
