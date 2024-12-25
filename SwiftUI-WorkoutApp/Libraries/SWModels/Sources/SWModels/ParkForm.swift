/// Форма для отправки при создании/изменении площадки
public struct ParkForm: Codable, Sendable {
    public var address: String
    public var latitude: String
    public var longitude: String
    public var cityID: Int
    public var typeID: Int
    public var sizeID: Int
    public let photosCount: Int
    public var newMediaFiles = [MediaFile]()

    public init(_ park: Park) {
        self.address = park.address ?? ""
        self.latitude = park.latitude
        self.longitude = park.longitude
        self.cityID = park.cityID ?? 0
        self.typeID = park.typeID
        self.sizeID = park.sizeID
        self.photosCount = park.photos.count
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
        self.typeID = ParkGrade.soviet.code
        self.sizeID = ParkSize.small.code
        self.photosCount = 0
    }
}

public extension ParkForm {
    var gradeString: String {
        get { ParkGrade(id: typeID).rawValue }
        set { typeID = Int(newValue) ?? 0 }
    }

    var sizeString: String {
        get { ParkSize(id: sizeID).rawValue }
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
    func isReadyToUpdate(old: ParkForm) -> Bool {
        let canSaveUpdated = [address, latitude, longitude].allSatisfy { !$0.isEmpty }
        return canSaveUpdated && self != old
    }
}

extension ParkForm: Equatable {
    public static func == (lhs: ParkForm, rhs: ParkForm) -> Bool {
        lhs.address == rhs.address
            && lhs.latitude == rhs.latitude
            && lhs.longitude == rhs.longitude
            && lhs.cityID == rhs.cityID
            && lhs.typeID == rhs.typeID
            && lhs.sizeID == rhs.sizeID
            && lhs.newMediaFiles == rhs.newMediaFiles
    }
}
