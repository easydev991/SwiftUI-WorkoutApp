import Foundation

enum AnalyticsEvent {
    case screenView(screen: AppScreen, source: AppScreen? = nil)
    case userAction(action: UserAction)
    case appError(kind: AppErrorKind, error: any Error)
}

extension AnalyticsEvent {
    enum AppScreen: String {
        case root
        case login
        case parksMap = "parks_map"
        case parksMapList = "parks_map_list"
        case parksListUsedBy = "parks_list_used_by"
        case parksListEvent = "parks_list_event"
        case parksAddedByUser = "parks_added_by_user"
        case parkDetail = "park_detail"
        case parkForm = "park_form"
        case parkFilter = "park_filter"
        case eventsList = "events_list"
        case eventDetail = "event_detail"
        case eventForm = "event_form"
        case dialogsList = "dialogs_list"
        case dialog
        case profileMainUser = "profile_main_user"
        case profileOtherUser = "profile_other_user"
        case mainUserFriendsList = "main_user_friends_list"
        case friendsList = "friends_list"
        case editProfile = "edit_profile"
        case changePassword = "change_password"
        case searchUsers = "search_users"
        case blackList = "black_list"
        case journalsList = "journals_list"
        case journalEntries = "journal_entries"
        case journalSettings = "journal_settings"
        case countryList = "country_list"
        case cityList = "city_list"
        case more
        case themeIcon = "theme_icon"
    }

    enum UserAction {
        case login
        case resetPassword
        case logout
        case saveProfile
        case savePassword
        case searchUsers
        case selectCountry(countryId: String, source: AppScreen)
        case selectCity(cityId: String, source: AppScreen)
        case sendFeedback(source: AppScreen)
        case reportPhoto(source: AppScreen)
        case reportComment(source: AppScreen)
        case addFriend
        case removeFriend
        case respondFriendRequestAccept
        case respondFriendRequestDecline
        case blockUser
        case unblockUser
        case sendMessage
        case openParksFilter
        case refreshParks
        case openCitySearch
        case clearCityFilter
        case selectParkFilterCity(cityId: String)
        case selectParkFilterType(type: String)
        case selectParkFilterSize(size: String)
        case selectParkAnnotation(parkId: Int)
        case openCitySearchEmptyState
        case openFilterEmptyState
        case createPark
        case savePark
        case deletePark
        case createEvent
        case saveEvent
        case deleteEvent
        case selectEventType(type: String)
        case createJournal
        case editJournal
        case deleteJournal
        case createJournalEntry
        case editJournalEntry
        case deleteJournalEntry
        case selectLanguage
        case selectTheme(theme: String)
        case selectAppIcon(iconName: String)
        case openLanguageSettings

        var name: String {
            switch self {
            case .login: "login"
            case .resetPassword: "reset_password"
            case .logout: "logout"
            case .saveProfile: "save_profile"
            case .savePassword: "save_password"
            case .searchUsers: "search_users"
            case .selectCountry: "select_country"
            case .selectCity: "select_city"
            case .sendFeedback: "send_feedback"
            case .reportPhoto: "report_photo"
            case .reportComment: "report_comment"
            case .addFriend: "add_friend"
            case .removeFriend: "remove_friend"
            case .respondFriendRequestAccept: "respond_friend_request_accept"
            case .respondFriendRequestDecline: "respond_friend_request_decline"
            case .blockUser: "block_user"
            case .unblockUser: "unblock_user"
            case .sendMessage: "send_message"
            case .openParksFilter: "open_parks_filter"
            case .refreshParks: "refresh_parks"
            case .openCitySearch: "open_city_search"
            case .clearCityFilter: "clear_city_filter"
            case .selectParkFilterCity: "select_park_filter_city"
            case .selectParkFilterType: "select_park_filter_type"
            case .selectParkFilterSize: "select_park_filter_size"
            case .selectParkAnnotation: "select_park_annotation"
            case .openCitySearchEmptyState: "open_city_search_empty_state"
            case .openFilterEmptyState: "open_filter_empty_state"
            case .createPark: "create_park"
            case .savePark: "save_park"
            case .deletePark: "delete_park"
            case .createEvent: "create_event"
            case .saveEvent: "save_event"
            case .deleteEvent: "delete_event"
            case .selectEventType: "select_event_type"
            case .createJournal: "create_journal"
            case .editJournal: "edit_journal"
            case .deleteJournal: "delete_journal"
            case .createJournalEntry: "create_journal_entry"
            case .editJournalEntry: "edit_journal_entry"
            case .deleteJournalEntry: "delete_journal_entry"
            case .selectLanguage: "select_language"
            case .selectTheme: "select_theme"
            case .selectAppIcon: "select_app_icon"
            case .openLanguageSettings: "open_language_settings"
            }
        }
    }

    enum AppErrorKind: String {
        case loginFailed = "login_failed"
        case passwordResetFailed = "password_reset_failed"
        case profileLoadFailed = "profile_load_failed"
        case countriesUpdateFailed = "countries_update_failed"
        case profileSaveFailed = "profile_save_failed"
        case changePasswordFailed = "change_password_failed"
        case searchUsersFailed = "search_users_failed"
        case friendRequestFailed = "friend_request_failed"
        case unblockFailed = "unblock_failed"
        case dialogsLoadFailed = "dialogs_load_failed"
        case dialogDeleteFailed = "dialog_delete_failed"
        case sendMessageFailed = "send_message_failed"
        case parkSaveFailed = "park_save_failed"
        case parkDeleteFailed = "park_delete_failed"
        case parkLoadFailed = "park_load_failed"
        case eventSaveFailed = "event_save_failed"
        case eventDeleteFailed = "event_delete_failed"
        case eventLoadFailed = "event_load_failed"
        case journalSaveFailed = "journal_save_failed"
        case journalDeleteFailed = "journal_delete_failed"
        case journalLoadFailed = "journal_load_failed"
        case selectCountryFailed = "select_country_failed"
        case selectCityFailed = "select_city_failed"
        case selectFilterFailed = "select_filter_failed"
        case themeChangeFailed = "theme_change_failed"
        case iconChangeFailed = "icon_change_failed"
    }
}
