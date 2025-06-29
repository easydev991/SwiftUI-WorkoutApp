import CoreLocation
import Foundation
import OSLog
import SWModels

/// Сервис для геокодирования координат в адрес и идентификатор города
struct GeocodingService {
    let coordinate: CLLocationCoordinate2D

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "GeocodingService",
        category: "GeocodingService"
    )

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }

    /// Выполняет геокодирование координат
    /// - Returns: Кортеж с адресом и идентификатором города
    /// - Throws: GeocodingError в случае ошибки
    func makeAddressAndCityId() async throws -> (address: String, cityId: Int) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        logger.debug("Запускаем CLGeocoder для координат: \(coordinate.latitude), \(coordinate.longitude)")

        let placemarks = try await CLGeocoder().reverseGeocodeLocation(
            location,
            preferredLocale: Locale(identifier: "ru_RU")
        )

        guard let firstPlacemark = placemarks.first else {
            logger.warning("CLGeocoder не вернул результатов")
            throw GeocodingError.noPlacemarkFound
        }

        logger.debug("CLGeocoder успешно завершил работу")

        let address = try makeAddress(from: firstPlacemark)
        let cityId = try makeCityId(from: firstPlacemark)

        return (address, cityId)
    }

    /// Создает адрес из placemark
    /// - Parameter placemark: Результат геокодирования
    /// - Returns: Полный адрес
    /// - Throws: GeocodingError.failedToCreateAddress если не удалось создать адрес
    private func makeAddress(from placemark: CLPlacemark) throws -> String {
        guard let address = SWAddress.makeAddress(for: placemark), !address.isEmpty else {
            logger.warning("Не удалось создать адрес из placemark")
            throw GeocodingError.failedToCreateAddress
        }
        logger.debug("Создан адрес: \(address)")
        return address
    }

    /// Определяет идентификатор города из placemark
    /// - Parameter placemark: Результат геокодирования
    /// - Returns: Идентификатор города
    /// - Throws: GeocodingError.failedToFindCityId если не удалось определить cityId
    private func makeCityId(from placemark: CLPlacemark) throws -> Int {
        guard let cityId = SWAddress.makeCityId(with: placemark.locality), cityId != 0 else {
            logger.warning("Не удалось определить cityId для locality: \(placemark.locality ?? "nil")")
            throw GeocodingError.failedToFindCityId
        }
        logger.debug("Определен cityId: \(cityId) для locality: \(placemark.locality ?? "nil")")
        return cityId
    }
}

extension GeocodingService {
    enum GeocodingError: Error, LocalizedError {
        case noPlacemarkFound
        case failedToCreateAddress
        case failedToFindCityId

        var errorDescription: String? {
            switch self {
            case .noPlacemarkFound:
                "CLGeocoder не вернул результатов геокодирования"
            case .failedToCreateAddress:
                "Не удалось создать адрес из результата геокодирования"
            case .failedToFindCityId:
                "Не удалось определить идентификатор города"
            }
        }
    }
}
