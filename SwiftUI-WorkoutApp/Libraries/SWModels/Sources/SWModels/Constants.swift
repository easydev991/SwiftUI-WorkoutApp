import Foundation

public enum Constants {
    /// Минимальная длина пароля
    public static let minPasswordSize = 6
    /// Лимит фотографий для одной площадки/мероприятия
    public static let photosLimit = 15
    /// Минимальный возраст пользователя (13 лет)
    public static let minUserAge = Calendar.current.date(byAdding: .year, value: -13, to: .now) ?? .now
    public static let appVersion = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? ""
    /// Получатели обратной связи
    public static let feedbackRecipient = ["info@workout.su", "cuties.84tilbury@icloud.com"]
}
