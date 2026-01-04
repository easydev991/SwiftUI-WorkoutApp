import Foundation
import SWKeychain
import SWModels
import Testing
@testable import WorkoutApp

@MainActor
struct DefaultsServiceTests {
    // MARK: - triggerLogout(manually:)

    @Test("triggerLogout(manually: true) должен вызывать authHelper.triggerLogout()")
    func triggerLogoutManuallyTrueCallsAuthHelper() {
        let mockAuthHelper = MockAuthHelperForDefaultsService()
        let defaultsService = DefaultsService(authHelper: mockAuthHelper)

        defaultsService.triggerLogout(manually: true)

        #expect(mockAuthHelper.triggerLogoutCallCount == 1)
    }

    @Test("triggerLogout(manually: false) не должен вызывать authHelper.triggerLogout()")
    func triggerLogoutManuallyFalseDoesNotCallAuthHelper() {
        let mockAuthHelper = MockAuthHelperForDefaultsService()
        let defaultsService = DefaultsService(authHelper: mockAuthHelper)

        defaultsService.triggerLogout(manually: false)

        #expect(mockAuthHelper.triggerLogoutCallCount == 0)
    }

    @Test("triggerLogout(manually: true) должен очищать данные пользователя")
    func triggerLogoutManuallyTrueClearsUserData() throws {
        let mockAuthHelper = MockAuthHelperForDefaultsService()
        let defaultsService = DefaultsService(authHelper: mockAuthHelper)

        let userInfo = UserResponse(id: 1, userName: "test")
        try defaultsService.saveUserInfo(userInfo)
        try defaultsService.saveFriendsIds([1, 2, 3])
        try defaultsService.saveFriendRequests([userInfo])
        try defaultsService.saveBlacklist([userInfo])
        defaultsService.saveUnreadMessagesCount(5)

        defaultsService.triggerLogout(manually: true)

        #expect(defaultsService.mainUserInfo == nil)
        #expect(defaultsService.friendsIdsList.isEmpty)
        #expect(defaultsService.friendRequestsList.isEmpty)
        #expect(defaultsService.blacklistedUsers.isEmpty)
        #expect(defaultsService.unreadMessagesCount == 0)
    }

    @Test("triggerLogout(manually: false) должен очищать данные пользователя")
    func triggerLogoutManuallyFalseClearsUserData() throws {
        let mockAuthHelper = MockAuthHelperForDefaultsService()
        let defaultsService = DefaultsService(authHelper: mockAuthHelper)

        let userInfo = UserResponse(id: 1, userName: "test")
        try defaultsService.saveUserInfo(userInfo)
        try defaultsService.saveFriendsIds([1, 2, 3])
        try defaultsService.saveFriendRequests([userInfo])
        try defaultsService.saveBlacklist([userInfo])
        defaultsService.saveUnreadMessagesCount(5)

        defaultsService.triggerLogout(manually: false)

        #expect(defaultsService.mainUserInfo == nil)
        #expect(defaultsService.friendsIdsList.isEmpty)
        #expect(defaultsService.friendRequestsList.isEmpty)
        #expect(defaultsService.blacklistedUsers.isEmpty)
        #expect(defaultsService.unreadMessagesCount == 0)
    }

    // MARK: - Автоматический выход при удалении authData

    @Test("При установке authData = nil в authHelper должен автоматически вызываться triggerLogout(manually: false)")
    func authDataNilTriggersAutomaticLogout() async throws {
        let mockAuthHelper = MockAuthHelperForDefaultsService(
            authData: AuthData(login: "test", password: "password")
        )
        let defaultsService = DefaultsService(authHelper: mockAuthHelper)

        let userInfo = UserResponse(id: 1, userName: "test")
        try defaultsService.saveUserInfo(userInfo)
        try defaultsService.saveFriendsIds([1, 2, 3])
        try defaultsService.saveFriendRequests([userInfo])
        try defaultsService.saveBlacklist([userInfo])
        defaultsService.saveUnreadMessagesCount(5)

        mockAuthHelper.setAuthData(nil)

        try await Task.sleep(nanoseconds: 200_000_000)

        #expect(defaultsService.mainUserInfo == nil)
        #expect(defaultsService.friendsIdsList.isEmpty)
        #expect(defaultsService.friendRequestsList.isEmpty)
        #expect(defaultsService.blacklistedUsers.isEmpty)
        #expect(defaultsService.unreadMessagesCount == 0)
        #expect(mockAuthHelper.triggerLogoutCallCount == 0)
    }

    @Test("При установке authData != nil не должен вызываться triggerLogout")
    func authDataNotNilDoesNotTriggerLogout() async throws {
        let mockAuthHelper = MockAuthHelperForDefaultsService(authData: nil)
        let defaultsService = DefaultsService(authHelper: mockAuthHelper)

        let userInfo = UserResponse(id: 1, userName: "test")
        try defaultsService.saveUserInfo(userInfo)
        try defaultsService.saveFriendsIds([1, 2, 3])

        mockAuthHelper.setAuthData(AuthData(login: "test", password: "password"))

        try await Task.sleep(nanoseconds: 200_000_000)

        let savedUserInfo = try #require(defaultsService.mainUserInfo)
        #expect(savedUserInfo.id == 1)
        #expect(defaultsService.friendsIdsList.count == 3)
    }

    @Test("При инициализации DefaultsService с authData = nil не должен вызываться triggerLogout")
    func initWithNilAuthDataDoesNotTriggerLogout() {
        let mockAuthHelper = MockAuthHelperForDefaultsService(authData: nil)
        let defaultsService = DefaultsService(authHelper: mockAuthHelper)

        #expect(defaultsService.mainUserInfo == nil)
        #expect(defaultsService.friendsIdsList.isEmpty)
        #expect(defaultsService.friendRequestsList.isEmpty)
        #expect(defaultsService.blacklistedUsers.isEmpty)
        #expect(defaultsService.unreadMessagesCount == 0)
        #expect(mockAuthHelper.triggerLogoutCallCount == 0)
    }
}
