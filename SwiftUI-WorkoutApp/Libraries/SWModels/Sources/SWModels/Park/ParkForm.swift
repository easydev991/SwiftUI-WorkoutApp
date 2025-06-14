/// Форма для отправки при создании/изменении площадки
public struct ParkForm: Codable, Sendable {
    public var address: String
    public var latitude: String
    public var longitude: String
    public var cityId: Int
    public var typeId: Int
    public var sizeId: Int
    public let photosCount: Int
    public var newMediaFiles = [MediaFile]()

    public init(_ park: Park) {
        self.address = park.address ?? ""
        self.latitude = park.latitude
        self.longitude = park.longitude
        self.cityId = park.cityId ?? 0
        self.typeId = park.typeId
        self.sizeId = park.sizeId
        self.photosCount = park.photos.count
    }

    public init(
        address: String,
        latitude: Double,
        longitude: Double,
        cityId: Int
    ) {
        self.address = address
        self.latitude = latitude.description
        self.longitude = longitude.description
        self.cityId = cityId
        self.typeId = ParkGrade.soviet.rawValue
        self.sizeId = ParkSize.small.rawValue
        self.photosCount = 0
    }
}

public extension ParkForm {
    var gradeString: String {
        get { ParkGrade(code: typeId).description }
        set { typeId = Int(newValue) ?? 0 }
    }

    var sizeString: String {
        get { ParkSize(code: sizeId).description }
        set { sizeId = Int(newValue) ?? 0 }
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
            && cityId != .zero
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
            && lhs.cityId == rhs.cityId
            && lhs.typeId == rhs.typeId
            && lhs.sizeId == rhs.sizeId
            && lhs.newMediaFiles == rhs.newMediaFiles
    }
}
