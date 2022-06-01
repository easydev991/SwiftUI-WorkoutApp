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
    var newImagesData = [MediaFile]()

    init(_ sportsGround: SportsGround) {
        address = sportsGround.address.valueOrEmpty
        latitude = sportsGround.latitude
        longitude = sportsGround.longitude
        cityID = sportsGround.cityID.valueOrZero
        typeID = sportsGround.typeID
        sizeID = sportsGround.sizeID
        photosCount = (sportsGround.photos?.count).valueOrZero
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
        typeID = SportsGroundGrade.soviet.code
        sizeID = SportsGroundSize.small.code
        photosCount = .zero
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
