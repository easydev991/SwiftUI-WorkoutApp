/// Форма для отправки при создании/изменении площадки
public struct SportsGroundForm: Codable, Sendable {
    public var address: String
    public var latitude: String
    public var longitude: String
    public var cityID: Int
    public var typeID: Int
    public var sizeID: Int
    public let photosCount: Int
    public var newMediaFiles = [MediaFile]()

    public init(_ sportsGround: SportsGround) {
        self.address = sportsGround.address ?? ""
        self.latitude = sportsGround.latitude
        self.longitude = sportsGround.longitude
        self.cityID = sportsGround.cityID ?? 0
        self.typeID = sportsGround.typeID
        self.sizeID = sportsGround.sizeID
        self.photosCount = sportsGround.photos.count
    }

    public init(
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
        self.photosCount = 0
    }
}

public extension SportsGroundForm {
    var gradeString: String {
        get { SportsGroundGrade(id: typeID).rawValue }
        set { typeID = Int(newValue) ?? 0 }
    }

    var sizeString: String {
        get { SportsGroundSize(id: sizeID).rawValue }
        set { sizeID = Int(newValue) ?? 0 }
    }

    /// Сколько еще фотографий можно добавить с учетом имеющихся
    var imagesLimit: Int {
        Constants.photosLimit - newMediaFiles.count - photosCount
    }

    /// Готовность формы к созданию новой площадки
    var isReadyToCreate: Bool {
        !address.isEmpty
            && !latitude.isEmpty
            && !longitude.isEmpty
            && cityID != .zero
            && !newMediaFiles.isEmpty
    }

    /// Готовность формы к отправке обновлений по площадке
    func isReadyToUpdate(old: SportsGroundForm) -> Bool {
        let canSaveUpdated = [address, latitude, longitude].allSatisfy { !$0.isEmpty }
        return canSaveUpdated && self != old
    }
}

extension SportsGroundForm: Equatable {
    public static func == (lhs: SportsGroundForm, rhs: SportsGroundForm) -> Bool {
        lhs.address == rhs.address
            && lhs.latitude == rhs.latitude
            && lhs.longitude == rhs.longitude
            && lhs.cityID == rhs.cityID
            && lhs.typeID == rhs.typeID
            && lhs.sizeID == rhs.sizeID
            && lhs.newMediaFiles == rhs.newMediaFiles
    }
}
