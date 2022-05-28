import Foundation

/// Форма для отправки при регистрации или изменении данных профиля
struct MainUserForm: Codable, Equatable {
    var userName, fullName, email, password: String
    var birthDate: Date
    var genderCode: Int
    var country: Country
    var city: City

    init(userName: String, fullName: String, email: String, password: String, birthDate: Date, gender: Int, country: Country, city: City) {
        self.userName = userName
        self.fullName = fullName
        self.email = email
        self.password = password
        self.birthDate = birthDate
        self.country = country
        self.city = city
        self.genderCode = gender
    }

    init(_ user: UserResponse) {
        self.userName = user.userName.valueOrEmpty
        self.fullName = user.fullName.valueOrEmpty
        self.email = user.email.valueOrEmpty
        self.password = ""
        self.birthDate = user.birthDate
        self.country = .init(cities: [], id: user.countryID.valueOrZero.description, name: "")
        self.city = .init(id: user.cityID.valueOrZero.description, name: "")
        self.genderCode = user.genderCode.valueOrZero
    }
}

extension MainUserForm {
    enum Placeholder: String {
        case userName = "Логин"
        case fullname = "Имя"
        case email = "email"
        case password = "Пароль (минимум 6 символов)"
        case birthDate = "Дата рождения"
        case country = "Страна"
        case city = "Город"
        case gender = "Пол"
    }

    func placeholder(_ element: Placeholder) -> String {
        element.rawValue
    }

    /// Пример: "1990-08-12T00:00:00.000Z"
    var birthDateIsoString: String {
        FormatterService.stringFromFullDate(birthDate)
    }

    /// Готовность формы к регистрации нового пользователя
    var isReadyToRegister: Bool {
        !userName.isEmpty
        && !email.isEmpty
        && password.count >= Constants.minPasswordSize
    }

    /// Готовность формы к сохранению обновленных данных
    var isReadyToSave: Bool {
        !userName.isEmpty
        && !email.isEmpty
        && !fullName.isEmpty
    }

    static var emptyValue: Self {
        .init(userName: "", fullName: "", email: "", password: "", birthDate: Constants.defaultUserAge, gender: .zero, country: .defaultCountry, city: .defaultCity)
    }
}
