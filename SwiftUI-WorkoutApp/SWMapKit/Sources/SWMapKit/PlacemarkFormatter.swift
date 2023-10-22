import CoreLocation

/// Модель для работы с `CLPlacemark`
public struct PlacemarkFormatter {
    private let placemark: CLPlacemark

    /// Инициализатор
    /// - Parameter placemark: Локация, из которой нужно достать краткий адрес
    public init(placemark: CLPlacemark) {
        self.placemark = placemark
    }

    /// Улица и номер дома
    private var streetAndHouse: String? {
        guard let street = placemark.thoroughfare, street.isEmpty else { return nil }
        return if let house = placemark.subThoroughfare {
            street + " " + house
        } else {
            street
        }
    }

    /// Обновляет старый адрес, если нужно
    ///
    /// - Новый адрес должен отличаться от старого
    /// - Адрес включает название улицы и номер дома, например "Яблочная 46"
    /// - Адрес используется при создании новой площадки
    public func updateIfNeeded(_ oldAddress: inout String) {
        if let streetAndHouse, streetAndHouse != oldAddress {
            oldAddress = streetAndHouse
            #if DEBUG
            print("Город: \(placemark.locality ?? "неизвестный")")
            print("Улица и номер дома: \(oldAddress)")
            #endif
        }
    }
}
