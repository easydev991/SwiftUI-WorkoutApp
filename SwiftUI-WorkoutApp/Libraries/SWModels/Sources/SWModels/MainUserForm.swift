import Foundation
import SWUtils

/// Форма для отправки при регистрации или изменении данных профиля
public struct MainUserForm: Codable, Equatable, Sendable {
    public var userName, fullName, email, password: String
    public var birthDate: Date
    public var genderCode: Int
    public var country: Country
    public var city: City
    public var image: MediaFile?

    public init(
        userName: String,
        fullName: String,
        email: String,
        password: String,
        birthDate: Date,
        gender: Int,
        country: Country,
        city: City,
        image: MediaFile? = nil
    ) {
        self.userName = userName
        self.fullName = fullName
        self.email = email
        self.password = password
        self.birthDate = birthDate
        self.country = country
        self.city = city
        self.genderCode = gender
        self.image = image
    }

    public init(_ user: UserResponse) {
        self.init(
            userName: user.userName ?? "",
            fullName: user.fullName ?? "",
            email: user.email ?? "",
            password: "",
            birthDate: user.birthDate,
            gender: user.genderCode ?? 0,
            country: .init(cities: [], id: (user.countryID ?? 0).description, name: ""),
            city: .init(id: (user.cityID ?? 0).description)
        )
    }
}

public extension MainUserForm {
    enum Placeholder: String {
        case userName = "Логин"
        case fullname = "Имя"
        case email
        case password = "Пароль (минимум 6 символов)"
        case birthDate = "Дата рождения"
        case country = "Страна"
        case city = "Город"
        case gender = "Пол"
    }

    var genderString: String {
        (Gender(genderCode) ?? .unspecified).rawValue
    }

    func placeholder(_ element: Placeholder) -> String {
        element.rawValue
    }

    /// Пример: "1990-08-12T00:00:00.000Z"
    var birthDateIsoString: String {
        DateFormatterService.stringFromFullDate(birthDate)
    }

    /// Готовность формы к регистрации нового пользователя
    var isReadyToRegister: Bool {
        !userName.isEmpty
            && !email.isEmpty
            && password.count >= Constants.minPasswordSize
            && genderCode != Gender.unspecified.code
            && birthDate <= Constants.minUserAge
    }

    /// Готовность формы к сохранению обновленных данных
    func isReadyToSave(comparedTo oldForm: MainUserForm) -> Bool {
        let isNewFormNotEmpty = !userName.isEmpty
            && !email.isEmpty
            && !fullName.isEmpty
            && genderCode != Gender.unspecified.code
            && birthDate <= Constants.minUserAge
        return isNewFormNotEmpty && self != oldForm
    }

    static var emptyValue: Self {
        .init(
            userName: "",
            fullName: "",
            email: "",
            password: "",
            birthDate: .now,
            gender: Gender.unspecified.code,
            country: .defaultCountry,
            city: .defaultCity
        )
    }
}
