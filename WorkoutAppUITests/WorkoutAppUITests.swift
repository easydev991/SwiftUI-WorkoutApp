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
        waitAndTapOrFail(timeout: 5, element: searchUsersButton)
        waitAndTapOrFail(element: searchUserField)
        searchUserField.typeText(Constants.usernameForSearch)
        searchUserField.typeText("\n") // жмем "return", чтобы начать поиск
        waitAndTapOrFail(timeout: 5, element: firstFoundUserCell)
        snapshot("5-profile", timeWaitingForIdle: 5)
        swipeToFind(element: usesSportsGroundsButton, in: app)
        waitAndTapOrFail(timeout: 5, element: firstSportsGroundCell)
        snapshot("2-sportsGroundDetails", timeWaitingForIdle: 5)
        waitAndTapOrFail(element: eventsTabButton)
        waitAndTapOrFail(element: pastEventsPickerButton)
        snapshot("3-pastEvents", timeWaitingForIdle: 5)
        waitAndTapOrFail(element: firstEventViewCell)
        snapshot("4-eventDetails", timeWaitingForIdle: 5)
    }
}

private extension WorkoutAppUITests {
    enum Constants {
        static let login = "testuserapple"
        static let password = "111111"
        static let usernameForSearch = "Ninenineone"
    }

    var grantLocationAccessButton: XCUIElement { springBoard.alerts.firstMatch.buttons["При использовании"] }
    var pasteButton: XCUIElement { app.menuItems["Вставить"] }
    var tabbar: XCUIElement { app.tabBars["Панель вкладок"] }
    var sportsGroundListPickerButton: XCUIElement { app.segmentedControls.firstMatch.buttons["Список"] }
    var profileTabButton: XCUIElement { tabbar.buttons["Профиль"] }
    var eventsTabButton: XCUIElement { tabbar.buttons["Мероприятия"] }
    var authorizeButton: XCUIElement { app.buttons["Авторизация"] }
    var loginField: XCUIElement { app.textFields["loginField"] }
    var passwordField: XCUIElement { app.secureTextFields["passwordField"] }
    var loginButton: XCUIElement { app.buttons["loginButton"] }
    var profileNavBar: XCUIElement { app.navigationBars["Профиль"] }
    var searchUsersButton: XCUIElement { profileNavBar.buttons["searchUsersButton"] }
    var searchUserField: XCUIElement { app.textFields["SearchUserNameField"] }
    var keyboardSearchButton: XCUIElement { app.keyboards.buttons["Search"] }
    var firstFoundUserCell: XCUIElement { app.buttons["UserViewCell"].firstMatch }
    var usesSportsGroundsButton: XCUIElement { app.buttons["usesSportsGroundsButton"] }
    var firstSportsGroundCell: XCUIElement { app.buttons["SportsGroundViewCell"].firstMatch }
    var pastEventsPickerButton: XCUIElement { app.segmentedControls.firstMatch.buttons["Прошедшие"] }
    var firstEventViewCell: XCUIElement { app.buttons["EventViewCell"].firstMatch }
}
