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
        waitAndTapOrFail(element: parksListPickerButton)
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
        sleep(1) // иногда симулятор начинает печатать раньше времени, поэтому ждем
        searchUserField.typeText(Constants.usernameForSearch)
        searchUserField.typeText("\n") // жмем "return", чтобы начать поиск
        waitAndTapOrFail(timeout: 10, element: firstFoundUserCell)
        waitForServerResponse()
        snapshot("5-profile", timeWaitingForIdle: 10)

        swipeToFind(element: usesParksButton, in: app)
        waitAndTapOrFail(timeout: 10, element: firstParkCell)
        snapshot("2-sportsGroundDetails", timeWaitingForIdle: 10)

        waitAndTapOrFail(timeout: 5, element: closeButton)
        swipeDownToClosePage(element: whereTrainsText)
        waitAndTapOrFail(timeout: 10, element: eventsTabButton)
        waitAndTapOrFail(timeout: 10, element: pastEventsPickerButton)
        waitForServerResponse()
        snapshot("3-pastEvents", timeWaitingForIdle: 10)

        waitAndTapOrFail(timeout: 10, element: firstEventViewCell)
        waitForServerResponse()
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

    /// Текст в навбаре модального окна
    var whereTrainsText: XCUIElement {
        let rusButton = app.staticTexts["Где тренируется"]
        let enButton = app.staticTexts["Where trains"]
        return rusButton.exists ? rusButton : enButton
    }

    var parksListPickerButton: XCUIElement { app.segmentedControls.firstMatch.buttons["Список"] }
    var profileTabButton: XCUIElement { tabbar.buttons["profile"] }
    var eventsTabButton: XCUIElement { tabbar.buttons["events"] }
    var authorizeButton: XCUIElement { app.buttons["authorizeButton"] }
    var loginField: XCUIElement { app.textFields["loginField"] }
    var passwordField: XCUIElement { app.secureTextFields["passwordField"] }
    var loginButton: XCUIElement { app.buttons["loginButton"] }
    var searchUsersButton: XCUIElement { app.buttons["searchUsersButton"] }
    var closeButton: XCUIElement { app.buttons["closeButton"] }
    var searchUserField: XCUIElement { app.searchFields.firstMatch }
    var keyboardSearchButton: XCUIElement { app.keyboards.buttons["Search"] }
    var firstFoundUserCell: XCUIElement { app.buttons["UserViewCell"].firstMatch }
    var usesParksButton: XCUIElement { app.buttons["usesParksButton"] }
    var firstParkCell: XCUIElement { app.buttons["ParkViewCell"].firstMatch }
    var pastEventsPickerButton: XCUIElement { app.segmentedControls.firstMatch.buttons["Прошедшие"] }
    var firstEventViewCell: XCUIElement { app.buttons["EventViewCell"].firstMatch }
}
