import Foundation

public enum Strings {
    public static let authInvitationText = NSLocalizedString(
        "Auth.Invitation",
        bundle: .module,
        comment: "Авторизуйтесь, чтобы иметь доступ ко всем возможностям"
    )
    public static let registrationInfoText = NSLocalizedString(
        "Registration.Info",
        bundle: .module,
        comment: "Регистрация доступна на сайте workout.su"
    )
    public static let doneTitle = NSLocalizedString(
        "Done",
        bundle: .module,
        comment: "Готово"
    )
    public static let errorTitle = NSLocalizedString(
        "Error",
        bundle: .module,
        comment: "Ошибка"
    )
}

public extension Strings {
    enum Alert {
        public static let forgotPassword = NSLocalizedString(
            "Alert.ForgotPassword",
            bundle: .module,
            comment: "Для восстановления пароля введите логин или email"
        )
        public static let friendRequestSent = NSLocalizedString(
            "Alert.FriendRequestSent",
            bundle: .module,
            comment: "Запрос отправлен!"
        )
        public static let deleteEvent = NSLocalizedString(
            "Alert.DeleteEvent",
            bundle: .module,
            comment: "Удалить мероприятие?"
        )
        public static let deletePark = NSLocalizedString(
            "Alert.DeletePark",
            bundle: .module,
            comment: "Удалить площадку?"
        )
        public static let deleteJournal = NSLocalizedString(
            "Alert.DeleteJournal",
            bundle: .module,
            comment: "Удалить дневник?"
        )
        public static let deleteJournalEntry = NSLocalizedString(
            "Alert.DeleteJournalEntry",
            bundle: .module,
            comment: "Удалить запись из дневника?"
        )
        public static let deleteDialog = NSLocalizedString(
            "Alert.DeleteDialog",
            bundle: .module,
            comment: "Удалить диалог?"
        )
        public static let logout = NSLocalizedString(
            "Alert.Logout",
            bundle: .module,
            comment: "Выйти из учетной записи?"
        )
        public static let parkFeedback = NSLocalizedString(
            "Alert.ParkFeedback",
            bundle: .module,
            comment: "Нужно обновить данные о площадке?"
        )
        public static let resetSuccessful = NSLocalizedString(
            "Alert.ResetSuccessful",
            bundle: .module,
            comment: "Инструкция для восстановления пароля выслана на email, указанный при регистрации"
        )
        public static let locationPermissionDenied = NSLocalizedString(
            "Alert.LocationPermissionDenied",
            bundle: .module,
            comment: "Запрещен доступ к геолокации"
        )
        public static let needLocationPermission = NSLocalizedString(
            "Alert.NeedLocationPermission",
            bundle: .module,
            comment: "Для отображения твоего местоположения необходимо разрешить доступ к геолокации в настройках"
        )
        public static let eventCreationRule = NSLocalizedString(
            "Alert.EventCreationRule",
            bundle: .module,
            comment: "Чтобы создать мероприятие, нужно указать хотя бы одну площадку, где ты тренируешься"
        )
        public static let userNotFound = NSLocalizedString(
            "Alert.UserNotFound",
            bundle: .module,
            comment: "Не удалось найти такого пользователя"
        )
    }
}
