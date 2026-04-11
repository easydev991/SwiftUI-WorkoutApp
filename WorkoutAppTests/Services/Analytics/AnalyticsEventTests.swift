import Foundation
import Testing
@testable import WorkoutApp

struct AnalyticsEventTests {
    @Test("UserAction.name возвращает корректные значения для ключевых кейсов")
    func userActionNameMapping() {
        let values: [(AnalyticsEvent.UserAction, String)] = [
            (.login, "login"),
            (.resetPassword, "reset_password"),
            (.logout, "logout"),
            (.saveProfile, "save_profile"),
            (.savePassword, "save_password"),
            (.searchUsers, "search_users"),
            (.selectCountry(countryId: "1", source: .editProfile), "select_country"),
            (.selectCity(cityId: "2", source: .editProfile), "select_city"),
            (.sendFeedback(source: .more), "send_feedback"),
            (.reportPhoto(source: .eventDetail), "report_photo"),
            (.reportComment(source: .eventDetail), "report_comment"),
            (.addFriend, "add_friend"),
            (.removeFriend, "remove_friend"),
            (.respondFriendRequestAccept, "respond_friend_request_accept"),
            (.respondFriendRequestDecline, "respond_friend_request_decline"),
            (.blockUser, "block_user"),
            (.unblockUser, "unblock_user"),
            (.sendMessage, "send_message"),
            (.openParksFilter, "open_parks_filter"),
            (.refreshParks, "refresh_parks"),
            (.openCitySearch, "open_city_search"),
            (.clearCityFilter, "clear_city_filter"),
            (.selectParkFilterCity(cityId: "5"), "select_park_filter_city"),
            (.selectParkFilterType(type: "workout"), "select_park_filter_type"),
            (.selectParkFilterSize(size: "medium"), "select_park_filter_size"),
            (.selectParkAnnotation(parkId: 5), "select_park_annotation"),
            (.openCitySearchEmptyState, "open_city_search_empty_state"),
            (.openFilterEmptyState, "open_filter_empty_state"),
            (.createPark, "create_park"),
            (.savePark, "save_park"),
            (.deletePark, "delete_park"),
            (.createEvent, "create_event"),
            (.saveEvent, "save_event"),
            (.deleteEvent, "delete_event"),
            (.selectEventType(type: "future"), "select_event_type"),
            (.createJournal, "create_journal"),
            (.editJournal, "edit_journal"),
            (.deleteJournal, "delete_journal"),
            (.createJournalEntry, "create_journal_entry"),
            (.editJournalEntry, "edit_journal_entry"),
            (.deleteJournalEntry, "delete_journal_entry"),
            (.selectLanguage, "select_language"),
            (.selectTheme(theme: "dark"), "select_theme"),
            (.selectAppIcon(iconName: "default"), "select_app_icon"),
            (.openLanguageSettings, "open_language_settings")
        ]

        for (action, expectedName) in values {
            #expect(action.name == expectedName)
        }
    }

    @Test("AppScreen rawValue совпадает с контрактом аналитики")
    func appScreenRawValues() {
        #expect(AnalyticsEvent.AppScreen.root.rawValue == "root")
        #expect(AnalyticsEvent.AppScreen.login.rawValue == "login")
        #expect(AnalyticsEvent.AppScreen.parksMap.rawValue == "parks_map")
        #expect(AnalyticsEvent.AppScreen.parksMapList.rawValue == "parks_map_list")
        #expect(AnalyticsEvent.AppScreen.parksListUsedBy.rawValue == "parks_list_used_by")
        #expect(AnalyticsEvent.AppScreen.parksListEvent.rawValue == "parks_list_event")
        #expect(AnalyticsEvent.AppScreen.parksAddedByUser.rawValue == "parks_added_by_user")
        #expect(AnalyticsEvent.AppScreen.parkDetail.rawValue == "park_detail")
        #expect(AnalyticsEvent.AppScreen.parkForm.rawValue == "park_form")
        #expect(AnalyticsEvent.AppScreen.parkFilter.rawValue == "park_filter")
        #expect(AnalyticsEvent.AppScreen.eventsList.rawValue == "events_list")
        #expect(AnalyticsEvent.AppScreen.eventDetail.rawValue == "event_detail")
        #expect(AnalyticsEvent.AppScreen.eventForm.rawValue == "event_form")
        #expect(AnalyticsEvent.AppScreen.dialogsList.rawValue == "dialogs_list")
        #expect(AnalyticsEvent.AppScreen.dialog.rawValue == "dialog")
        #expect(AnalyticsEvent.AppScreen.profileMainUser.rawValue == "profile_main_user")
        #expect(AnalyticsEvent.AppScreen.profileOtherUser.rawValue == "profile_other_user")
        #expect(AnalyticsEvent.AppScreen.mainUserFriendsList.rawValue == "main_user_friends_list")
        #expect(AnalyticsEvent.AppScreen.friendsList.rawValue == "friends_list")
        #expect(AnalyticsEvent.AppScreen.editProfile.rawValue == "edit_profile")
        #expect(AnalyticsEvent.AppScreen.changePassword.rawValue == "change_password")
        #expect(AnalyticsEvent.AppScreen.searchUsers.rawValue == "search_users")
        #expect(AnalyticsEvent.AppScreen.blackList.rawValue == "black_list")
        #expect(AnalyticsEvent.AppScreen.journalsList.rawValue == "journals_list")
        #expect(AnalyticsEvent.AppScreen.journalEntries.rawValue == "journal_entries")
        #expect(AnalyticsEvent.AppScreen.journalSettings.rawValue == "journal_settings")
        #expect(AnalyticsEvent.AppScreen.countryList.rawValue == "country_list")
        #expect(AnalyticsEvent.AppScreen.cityList.rawValue == "city_list")
        #expect(AnalyticsEvent.AppScreen.more.rawValue == "more")
        #expect(AnalyticsEvent.AppScreen.themeIcon.rawValue == "theme_icon")
    }

    @Test("AppErrorKind rawValue совпадает с контрактом аналитики")
    func appErrorKindRawValues() {
        #expect(AnalyticsEvent.AppErrorKind.loginFailed.rawValue == "login_failed")
        #expect(AnalyticsEvent.AppErrorKind.passwordResetFailed.rawValue == "password_reset_failed")
        #expect(AnalyticsEvent.AppErrorKind.profileLoadFailed.rawValue == "profile_load_failed")
        #expect(AnalyticsEvent.AppErrorKind.countriesUpdateFailed.rawValue == "countries_update_failed")
        #expect(AnalyticsEvent.AppErrorKind.profileSaveFailed.rawValue == "profile_save_failed")
        #expect(AnalyticsEvent.AppErrorKind.changePasswordFailed.rawValue == "change_password_failed")
        #expect(AnalyticsEvent.AppErrorKind.searchUsersFailed.rawValue == "search_users_failed")
        #expect(AnalyticsEvent.AppErrorKind.friendRequestFailed.rawValue == "friend_request_failed")
        #expect(AnalyticsEvent.AppErrorKind.unblockFailed.rawValue == "unblock_failed")
        #expect(AnalyticsEvent.AppErrorKind.dialogsLoadFailed.rawValue == "dialogs_load_failed")
        #expect(AnalyticsEvent.AppErrorKind.dialogDeleteFailed.rawValue == "dialog_delete_failed")
        #expect(AnalyticsEvent.AppErrorKind.sendMessageFailed.rawValue == "send_message_failed")
        #expect(AnalyticsEvent.AppErrorKind.parkSaveFailed.rawValue == "park_save_failed")
        #expect(AnalyticsEvent.AppErrorKind.parkDeleteFailed.rawValue == "park_delete_failed")
        #expect(AnalyticsEvent.AppErrorKind.parkLoadFailed.rawValue == "park_load_failed")
        #expect(AnalyticsEvent.AppErrorKind.eventSaveFailed.rawValue == "event_save_failed")
        #expect(AnalyticsEvent.AppErrorKind.eventDeleteFailed.rawValue == "event_delete_failed")
        #expect(AnalyticsEvent.AppErrorKind.eventLoadFailed.rawValue == "event_load_failed")
        #expect(AnalyticsEvent.AppErrorKind.journalSaveFailed.rawValue == "journal_save_failed")
        #expect(AnalyticsEvent.AppErrorKind.journalDeleteFailed.rawValue == "journal_delete_failed")
        #expect(AnalyticsEvent.AppErrorKind.journalLoadFailed.rawValue == "journal_load_failed")
        #expect(AnalyticsEvent.AppErrorKind.selectCountryFailed.rawValue == "select_country_failed")
        #expect(AnalyticsEvent.AppErrorKind.selectCityFailed.rawValue == "select_city_failed")
        #expect(AnalyticsEvent.AppErrorKind.selectFilterFailed.rawValue == "select_filter_failed")
        #expect(AnalyticsEvent.AppErrorKind.themeChangeFailed.rawValue == "theme_change_failed")
        #expect(AnalyticsEvent.AppErrorKind.iconChangeFailed.rawValue == "icon_change_failed")
    }
}
