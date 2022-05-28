import Foundation
import CoreLocation.CLLocation

/// Форма для отправки при создании/изменении площадки
struct SportsGroundForm: Codable {
    var address: String
    var latitude: String
    var longitude: String
    var cityID: Int
    var typeID: Int
    var sizeID: Int
    let photosCount: Int
    var newImagesData = [MediaFile]()

    init(_ sportsGround: SportsGround? = nil) {
        address = (sportsGround?.address).valueOrEmpty
        latitude = (sportsGround?.latitude).valueOrEmpty
        longitude = (sportsGround?.longitude).valueOrEmpty
        cityID = (sportsGround?.cityID).valueOrZero
        typeID = sportsGround?.typeID ?? SportsGroundGrade.soviet.code
        sizeID = sportsGround?.sizeID ?? SportsGroundSize.small.code
        photosCount = (sportsGround?.photos?.count).valueOrZero
    }

    init(
        address: String,
        coordinate: CLLocationCoordinate2D,
        cityID: Int
    ) {
        self.address = address
        self.latitude = coordinate.latitude.description
        self.longitude = coordinate.longitude.description
        self.cityID = cityID
        typeID = SportsGroundGrade.soviet.code
        sizeID = SportsGroundSize.small.code
        photosCount = .zero
    }
}

extension SportsGroundForm {
    var coordinate: CLLocationCoordinate2D {
        get { .init(latitude: Double(latitude) ?? .zero, longitude: Double(longitude) ?? .zero) }
        set {
            latitude = newValue.latitude.description
            longitude = newValue.longitude.description
        }
    }
    var gradeString: String {
        get { SportsGroundGrade(id: typeID).rawValue }
        set { typeID = Int(newValue).valueOrZero }
    }

    var sizeString: String {
        get { SportsGroundSize(id: sizeID).rawValue }
        set { sizeID = Int(newValue).valueOrZero }
    }

    /// Готовность формы к созданию новой площадки
    var isReadyToCreate: Bool {
        !address.isEmpty
        && !latitude.isEmpty
        && !longitude.isEmpty
        && cityID != .zero
        && !newImagesData.isEmpty
    }

    /// Готовность формы к отправке обновлений по площадке
    var isReadyToSend: Bool {
        !address.isEmpty
        && !latitude.isEmpty
        && !longitude.isEmpty
        && cityID != .zero
    }
}
