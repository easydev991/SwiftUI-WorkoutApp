import XCTest

final class WorkoutAppUITests: XCTestCase {
    private let springBoard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("UITest")
        setupSnapshot(app)
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
        app.launchArguments.removeAll()
        app = nil
    }

    func testMakeScreenshots() {
        waitAndTap(timeout: 5, element: grantLocationAccessButton)
        waitAndTapOrFail(element: sportsGroundListPickerButton)
        app.swipeUp(velocity: .slow)
        snapshot("1-sportsGroundsList", timeWaitingForIdle: 5)
        waitAndTapOrFail(timeout: 5, element: profileTabButton)
        waitAndTapOrFail(element: authorizeButton)
        waitAndTapOrFail(element: loginField)
        loginField.typeText(Constants.login)
        waitAndTapOrFail(element: passwordField)
        passwordField.typeText(Constants.password)
        waitAndTapOrFail(element: loginButton)
        waitAndTapOrFail(timeout: 10, element: searchUsersButton)
        waitAndTapOrFail(timeout: 10, element: searchUserField)
        searchUserField.typeText(Constants.usernameForSearch)
        searchUserField.typeText("\n") // жмем "return", чтобы начать поиск
        waitAndTapOrFail(timeout: 10, element: firstFoundUserCell)
        sleep(5)
        snapshot("5-profile", timeWaitingForIdle: 10)
        swipeToFind(element: usesSportsGroundsButton, in: app)
        waitAndTapOrFail(timeout: 10, element: firstSportsGroundCell)
        snapshot("2-sportsGroundDetails", timeWaitingForIdle: 10)
        waitAndTapOrFail(timeout: 10, element: eventsTabButton)
        waitAndTapOrFail(timeout: 10, element: pastEventsPickerButton)
        sleep(5)
        snapshot("3-pastEvents", timeWaitingForIdle: 10)
        waitAndTapOrFail(timeout: 10, element: firstEventViewCell)
        sleep(5)
        snapshot("4-eventDetails", timeWaitingForIdle: 10)
    }
}

private extension WorkoutAppUITests {
    enum Constants {
        static let login = "testuserapple"
        static let password = "111111"
        static let usernameForSearch = "Ninenineone"
    }

    var grantLocationAccessButton: XCUIElement {
        let rusButton = springBoard.alerts.firstMatch.buttons["При использовании"]
        let enButton = springBoard.alerts.firstMatch.buttons["Allow While Using App"]
        return rusButton.exists ? rusButton : enButton
    }

    var tabbar: XCUIElement {
        let rusButton = app.tabBars["Панель вкладок"]
        let enButton = app.tabBars["Tab Bar"]
        return rusButton.exists ? rusButton : enButton
    }

    var sportsGroundListPickerButton: XCUIElement { app.segmentedControls.firstMatch.buttons["Список"] }
    var profileTabButton: XCUIElement { tabbar.buttons["profile"] }
    var eventsTabButton: XCUIElement { tabbar.buttons["events"] }
    var authorizeButton: XCUIElement { app.buttons["authorizeButton"] }
    var loginField: XCUIElement { app.textFields["loginField"] }
    var passwordField: XCUIElement { app.secureTextFields["passwordField"] }
    var loginButton: XCUIElement { app.buttons["loginButton"] }
    var searchUsersButton: XCUIElement { app.buttons["searchUsersButton"] }
    var searchUserField: XCUIElement { app.searchFields.firstMatch }
    var keyboardSearchButton: XCUIElement { app.keyboards.buttons["Search"] }
    var firstFoundUserCell: XCUIElement { app.buttons["UserViewCell"].firstMatch }
    var usesSportsGroundsButton: XCUIElement { app.buttons["usesSportsGroundsButton"] }
    var firstSportsGroundCell: XCUIElement { app.buttons["SportsGroundViewCell"].firstMatch }
    var pastEventsPickerButton: XCUIElement { app.segmentedControls.firstMatch.buttons["Прошедшие"] }
    var firstEventViewCell: XCUIElement { app.buttons["EventViewCell"].firstMatch }
}
