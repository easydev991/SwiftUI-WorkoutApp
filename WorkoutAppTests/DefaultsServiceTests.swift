import Foundation
import SWKeychain
import SWModels
import Testing
@testable import WorkoutApp

/// Сьюты, которые чистят общий UserDefaults.standard (@AppStorage в DefaultsService
/// на него перенаправляется, изолированный suite — не вариант): родитель с .serialized
/// выполняет их последовательно, чтобы очистки не перемешивались между сьютами
@Suite("Тесты с общим UserDefaults.standard", .serialized)
enum UserDefaultsIsolatedTests {}

extension UserDefaultsIsolatedTests {
    @MainActor
    struct DefaultsServiceTests {
        // MARK: - triggerLogout(manually:)

        @Test("triggerLogout(manually: true) должен вызывать authHelper.triggerLogout()")
        func triggerLogoutManuallyTrueCallsAuthHelper() {
            let (defaultsService, mockAuthHelper) = TestDefaults.makeDefaultsService()

            defaultsService.triggerLogout(manually: true)

            #expect(mockAuthHelper.triggerLogoutCallCount == 1)
        }

        @Test("triggerLogout(manually: false) не должен вызывать authHelper.triggerLogout()")
        func triggerLogoutManuallyFalseDoesNotCallAuthHelper() {
            let (defaultsService, mockAuthHelper) = TestDefaults.makeDefaultsService()

            defaultsService.triggerLogout(manually: false)

            #expect(mockAuthHelper.triggerLogoutCallCount == 0)
        }

        @Test("triggerLogout(manually: true) должен очищать данные пользователя")
        func triggerLogoutManuallyTrueClearsUserData() throws {
            let (defaultsService, _) = TestDefaults.makeDefaultsService()

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
            let (defaultsService, _) = TestDefaults.makeDefaultsService()

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
            let (defaultsService, mockAuthHelper) = TestDefaults.makeDefaultsService(
                authData: AuthData(login: "test", password: "password")
            )

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
            let (defaultsService, mockAuthHelper) = TestDefaults.makeDefaultsService()

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
            let (defaultsService, mockAuthHelper) = TestDefaults.makeDefaultsService()

            #expect(defaultsService.mainUserInfo == nil)
            #expect(defaultsService.friendsIdsList.isEmpty)
            #expect(defaultsService.friendRequestsList.isEmpty)
            #expect(defaultsService.blacklistedUsers.isEmpty)
            #expect(defaultsService.unreadMessagesCount == 0)
            #expect(mockAuthHelper.triggerLogoutCallCount == 0)
        }

        // MARK: - getProfileBadgeCount(isMissingAddress:)

        @Test("getProfileBadgeCount с isMissingAddress = true должен возвращать friendRequests + badgeValue")
        func getProfileBadgeCountWithMissingAddress() throws {
            let (defaultsService, _) = TestDefaults.makeDefaultsService()

            let userInfo = UserResponse(id: 1, userName: "test", cityId: nil, countryId: nil)
            try defaultsService.saveUserInfo(userInfo)

            let friendRequest1 = UserResponse(id: 2, userName: "friend1")
            let friendRequest2 = UserResponse(id: 3, userName: "friend2")
            try defaultsService.saveFriendRequests([friendRequest1, friendRequest2])

            let result = defaultsService.getProfileBadgeCount(isMissingAddress: true)

            #expect(result == 4)
        }

        @Test("getProfileBadgeCount с isMissingAddress = true и badgeValue = 0 должен возвращать только friendRequests")
        func getProfileBadgeCountWithMissingAddressAndZeroBadgeValue() throws {
            let (defaultsService, _) = TestDefaults.makeDefaultsService()

            let userInfo = UserResponse(id: 1, userName: "test", cityId: 1, countryId: 1)
            try defaultsService.saveUserInfo(userInfo)

            let friendRequest1 = UserResponse(id: 2, userName: "friend1")
            let friendRequest2 = UserResponse(id: 3, userName: "friend2")
            try defaultsService.saveFriendRequests([friendRequest1, friendRequest2])

            let result = defaultsService.getProfileBadgeCount(isMissingAddress: true)

            #expect(result == 2)
        }

        @Test("getProfileBadgeCount с isMissingAddress = false должен возвращать только friendRequests")
        func getProfileBadgeCountWithoutMissingAddress() throws {
            let (defaultsService, _) = TestDefaults.makeDefaultsService()

            let userInfo = UserResponse(id: 1, userName: "test", cityId: nil, countryId: nil)
            try defaultsService.saveUserInfo(userInfo)

            let friendRequest1 = UserResponse(id: 2, userName: "friend1")
            let friendRequest2 = UserResponse(id: 3, userName: "friend2")
            try defaultsService.saveFriendRequests([friendRequest1, friendRequest2])

            let result = defaultsService.getProfileBadgeCount(isMissingAddress: false)

            #expect(result == 2)
        }

        @Test("getProfileBadgeCount с isMissingAddress = true должен возвращать friendRequests + badgeValue", arguments: [
            (friendRequestsCount: 0, cityId: nil, countryId: nil),
            (friendRequestsCount: 0, cityId: 1, countryId: nil),
            (friendRequestsCount: 0, cityId: nil, countryId: 1),
            (friendRequestsCount: 3, cityId: nil, countryId: nil),
            (friendRequestsCount: 3, cityId: 1, countryId: nil),
            (friendRequestsCount: 3, cityId: nil, countryId: 1)
        ])
        func getProfileBadgeCountWithMissingAddress(
            friendRequestsCount: Int,
            cityId: Int?,
            countryId: Int?
        ) throws {
            let (defaultsService, _) = TestDefaults.makeDefaultsService()

            let userInfo = UserResponse(id: 1, userName: "test", cityId: cityId, countryId: countryId)
            try defaultsService.saveUserInfo(userInfo)

            var friendRequests: [UserResponse] = []
            for i in 0 ..< friendRequestsCount {
                friendRequests.append(UserResponse(id: i + 2, userName: "friend\(i)"))
            }
            try defaultsService.saveFriendRequests(friendRequests)

            let result = defaultsService.getProfileBadgeCount(isMissingAddress: true)
            let cityBadgeValue = cityId == nil ? 1 : 0
            let countryBadgeValue = countryId == nil ? 1 : 0
            let expected = friendRequestsCount + cityBadgeValue + countryBadgeValue

            #expect(result == expected)
        }

        @Test("getProfileBadgeCount с isMissingAddress = true и полным адресом должен возвращать только friendRequests", arguments: [
            (friendRequestsCount: 0, cityId: 1, countryId: 1),
            (friendRequestsCount: 3, cityId: 1, countryId: 1)
        ])
        func getProfileBadgeCountWithMissingAddressAndFullAddress(
            friendRequestsCount: Int,
            cityId: Int,
            countryId: Int
        ) throws {
            let (defaultsService, _) = TestDefaults.makeDefaultsService()

            let userInfo = UserResponse(id: 1, userName: "test", cityId: cityId, countryId: countryId)
            try defaultsService.saveUserInfo(userInfo)

            var friendRequests: [UserResponse] = []
            for i in 0 ..< friendRequestsCount {
                friendRequests.append(UserResponse(id: i + 2, userName: "friend\(i)"))
            }
            try defaultsService.saveFriendRequests(friendRequests)

            let result = defaultsService.getProfileBadgeCount(isMissingAddress: true)

            #expect(result == friendRequestsCount)
        }

        @Test("getProfileBadgeCount с isMissingAddress = false должен возвращать только friendRequests", arguments: [
            (friendRequestsCount: 0, cityId: nil, countryId: nil),
            (friendRequestsCount: 0, cityId: 1, countryId: 1),
            (friendRequestsCount: 3, cityId: nil, countryId: nil),
            (friendRequestsCount: 3, cityId: 1, countryId: 1)
        ])
        func getProfileBadgeCountWithoutMissingAddress(
            friendRequestsCount: Int,
            cityId: Int?,
            countryId: Int?
        ) throws {
            let (defaultsService, _) = TestDefaults.makeDefaultsService()

            let userInfo = UserResponse(id: 1, userName: "test", cityId: cityId, countryId: countryId)
            try defaultsService.saveUserInfo(userInfo)

            var friendRequests: [UserResponse] = []
            for i in 0 ..< friendRequestsCount {
                friendRequests.append(UserResponse(id: i + 2, userName: "friend\(i)"))
            }
            try defaultsService.saveFriendRequests(friendRequests)

            let result = defaultsService.getProfileBadgeCount(isMissingAddress: false)

            #expect(result == friendRequestsCount)
        }
    }
}
