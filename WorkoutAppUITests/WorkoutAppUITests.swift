import XCTest

final class WorkoutAppUITests: XCTestCase {
    @MainActor private let springBoard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    private var app: XCUIApplication!

    @MainActor
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("UITest")
        setupSnapshot(app)
        app.launch()
    }

    @MainActor
    override func tearDown() {
        super.tearDown()
        app.launchArguments.removeAll()
        app = nil
    }

    @MainActor
    func testMakeScreenshots() {
        waitAndTap(timeout: 5, element: grantLocationAccessButton)
        waitAndTap(timeout: 5, element: grantNotificationAccessButton)
        waitAndTapOrFail(timeout: 10, element: parksListPickerButton)
        waitForServerResponse()
        snapshot("1-sportsGroundsList")

        waitAndTapOrFail(timeout: 10, element: firstParkCell)
        waitForServerResponse()
        snapshot("2-sportsGroundDetails")
        waitAndTapOrFail(timeout: 5, element: closeButton)

        waitAndTapOrFail(timeout: 10, element: eventsTabButton)
        waitAndTapOrFail(timeout: 10, element: pastEventsPickerButton)
        waitForServerResponse()
        snapshot("3-pastEvents")

        waitAndTapOrFail(timeout: 10, element: firstEventViewCell)
        waitForServerResponse()
        snapshot("4-eventDetails")
        waitAndTapOrFail(timeout: 5, element: closeButton)

        waitAndTapOrFail(timeout: 5, element: profileTabButton)
        waitAndTapOrFail(element: authorizeButton)
        waitAndTapOrFail(element: loginField)
        loginField.typeText(Constants.login)
        waitAndTapOrFail(element: passwordField)
        passwordField.typeText(Constants.password)
        waitAndTapOrFail(element: loginButton)
        waitAndTapOrFail(timeout: 10, element: searchUsersButton)
        waitAndTapOrFail(timeout: 10, element: searchUserField)
        sleep(1) // иногда симулятор начинает печатать раньше времени, поэтому ждем
        searchUserField.typeText(Constants.usernameForSearch)
        searchUserField.typeText("\n") // жмем "return", чтобы начать поиск
        waitAndTapOrFail(timeout: 10, element: firstFoundUserCell)
        waitForServerResponse()
        snapshot("5-profile")
    }
}

@MainActor
private extension WorkoutAppUITests {
    enum Constants {
        static let login = "testuserapple"
        static let password = "111111"
        static let usernameForSearch = "Ninenineone"
    }

    var grantLocationAccessButton: XCUIElement {
        let rusButton = springBoard.alerts.firstMatch.buttons["При использовании приложения"]
        let enButton = springBoard.alerts.firstMatch.buttons["Allow While Using App"]
        return rusButton.exists ? rusButton : enButton
    }

    var grantNotificationAccessButton: XCUIElement {
        let rusButton = springBoard.alerts.firstMatch.buttons["Разрешить"]
        let enButton = springBoard.alerts.firstMatch.buttons["Allow"]
        return rusButton.exists ? rusButton : enButton
    }

    var tabbar: XCUIElement {
        let rusButton = app.tabBars["Панель вкладок"]
        let enButton = app.tabBars["Tab Bar"]
        return rusButton.exists ? rusButton : enButton
    }

    var parksListPickerButton: XCUIElement { app.segmentedControls.firstMatch.buttons["Список"] }
    var profileTabButton: XCUIElement {
        let rusButton = tabbar.buttons["Профиль"]
        let enButton = tabbar.buttons["Profile"]
        return rusButton.exists ? rusButton : enButton
    }

    var eventsTabButton: XCUIElement {
        let rusButton = tabbar.buttons["Мероприятия"]
        let enButton = tabbar.buttons["Events"]
        return rusButton.exists ? rusButton : enButton
    }

    var authorizeButton: XCUIElement { app.buttons["authorizeButton"] }
    var loginField: XCUIElement { app.textFields["loginField"] }
    var passwordField: XCUIElement { app.secureTextFields["passwordField"] }
    var loginButton: XCUIElement { app.buttons["loginButton"] }
    var searchUsersButton: XCUIElement { app.buttons["searchUsersButton"] }
    var closeButton: XCUIElement { app.buttons["closeButton"] }
    var searchUserField: XCUIElement { app.searchFields.firstMatch }
    var firstFoundUserCell: XCUIElement { app.buttons["UserViewCell"].firstMatch }
    var firstParkCell: XCUIElement { app.buttons["ParkViewCell"].firstMatch }
    var pastEventsPickerButton: XCUIElement { app.segmentedControls.firstMatch.buttons["Прошедшие"] }
    var firstEventViewCell: XCUIElement { app.buttons["EventViewCell"].firstMatch }
}
