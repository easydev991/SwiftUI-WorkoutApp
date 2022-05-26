import Foundation
import MapKit.MKGeometry

/// Форма для отправки при создании/изменении площадки
struct SportsGroundForm: Codable {
    var address: String
    var latitude: String
    var longitude: String
    var cityID: Int
    var typeID: Int
    var sizeID: Int

    init(_ sportsGround: SportsGround? = nil) {
        address = (sportsGround?.address).valueOrEmpty
        latitude = (sportsGround?.latitude).valueOrEmpty
        longitude = (sportsGround?.longitude).valueOrEmpty
        cityID = (sportsGround?.cityID).valueOrZero
        typeID = sportsGround?.typeID ?? SportsGroundGrade.soviet.code
        sizeID = sportsGround?.sizeID ?? SportsGroundSize.small.code
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

    var isReadyToSend: Bool {
        !address.isEmpty
        && !latitude.isEmpty
        && !longitude.isEmpty
        && cityID != .zero
    }
}
