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
        waitAndTap(timeout: 4, element: grantLocationAccessButton)
        waitAndTapOrFail(timeout: 4, element: profileTabButton)
        waitAndTapOrFail(element: authorizeButton)
        waitAndTapOrFail(element: loginField)
        loginField.typeText(Constants.login)
        waitAndTapOrFail(element: passwordField)
        passwordField.typeText(Constants.password)
        waitAndTapOrFail(element: loginButton)
        waitAndTapOrFail(timeout: 4, element: searchUsersButton)
        waitAndTapOrFail(element: searchUserField)
        searchUserField.typeText(Constants.usernameForSearch)
        searchUserField.typeText("\n") // жмем "return", чтобы начать поиск
        waitAndTapOrFail(timeout: 4, element: firstFoundUserCell)
        snapshot("1-profile", timeWaitingForIdle: 3)
        swipeToFind(element: usesSportsGroundsButton, in: app)
        waitAndTapOrFail(timeout: 4, element: firstSportsGroundCell)
        snapshot("2-sportsGroundDetails", timeWaitingForIdle: 3)
        waitAndTapOrFail(element: eventsTabButton)
        waitAndTapOrFail(element: pastEventsPickerButton)
        snapshot("3-pastEvents", timeWaitingForIdle: 3)
        waitAndTapOrFail(element: firstEventViewCell)
        snapshot("4-eventDetails", timeWaitingForIdle: 3)
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
