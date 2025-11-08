import Foundation

public enum Strings {
    public static let authInvitationText = String(localized: .authInvitation)
    public static let registrationInfoText = String(localized: .registrationInfo)
    public static let doneTitle = String(localized: .done)
    public static let errorTitle = String(localized: .error)
}

public extension Strings {
    enum Alert {
        public static let forgotPassword = String(localized: .alertForgotPassword)
        public static let friendRequestSent = String(localized: .alertFriendRequestSent)
        public static let deleteEvent = String(localized: .alertDeleteEvent)
        public static let deletePark = String(localized: .alertDeletePark)
        public static let deleteJournal = String(localized: .alertDeleteJournal)
        public static let deleteJournalEntry = String(localized: .alertDeleteJournalEntry)
        public static let deleteDialog = String(localized: .alertDeleteDialog)
        public static let logout = String(localized: .alertLogout)
        public static let parkFeedback = String(localized: .alertParkFeedback)
        public static let resetSuccessful = String(localized: .alertResetSuccessful)
        public static let locationPermissionDenied = String(localized: .alertLocationPermissionDenied)
        public static let needLocationPermission = String(localized: .alertNeedLocationPermission)
        public static let eventCreationRule = String(localized: .alertEventCreationRule)
        public static let userNotFound = String(localized: .alertUserNotFound)
    }
}
