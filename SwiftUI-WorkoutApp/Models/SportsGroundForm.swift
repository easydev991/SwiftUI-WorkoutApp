import Foundation

/// Форма для отправки при создании/изменении площадки
struct SportsGroundForm: Codable {
    var address: String
    var latitude: String
    var longitude: String
    var cityID: Int
    var typeID: Int
    var sizeID: Int
    let photosCount: Int
    var newMediaFiles = [MediaFile]()

    init(_ sportsGround: SportsGround) {
        self.address = sportsGround.address.valueOrEmpty
        self.latitude = sportsGround.latitude
        self.longitude = sportsGround.longitude
        self.cityID = sportsGround.cityID.valueOrZero
        self.typeID = sportsGround.typeID
        self.sizeID = sportsGround.sizeID
        self.photosCount = sportsGround.photos.count
    }

    init(
        address: String,
        latitude: Double,
        longitude: Double,
        cityID: Int
    ) {
        self.address = address
        self.latitude = latitude.description
        self.longitude = longitude.description
        self.cityID = cityID
        self.typeID = SportsGroundGrade.soviet.code
        self.sizeID = SportsGroundSize.small.code
        self.photosCount = .zero
    }
}

extension SportsGroundForm {
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
    }

    /// Готовность формы к отправке обновлений по площадке
    func isReadyToUpdate(old: SportsGroundForm) -> Bool {
        isReadyToCreate && (self != old)
    }
}

extension SportsGroundForm: Equatable {
    static func == (lhs: SportsGroundForm, rhs: SportsGroundForm) -> Bool {
        lhs.address == rhs.address
        && lhs.latitude == rhs.latitude
        && lhs.longitude == rhs.longitude
        && lhs.cityID == rhs.cityID
        && lhs.typeID == rhs.typeID
        && lhs.sizeID == rhs.sizeID
    }
}
