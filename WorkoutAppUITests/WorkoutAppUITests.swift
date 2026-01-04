import XCTest

@MainActor
final class WorkoutAppUITests: XCTestCase {
    private let springBoard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    private var app: XCUIApplication!
    private let login = "testuserapple"
    private let password = "111111"
    private let usernameForSearch = "Ninenineone"

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("UITest")
        setupSnapshot(app)
        app.launch()
    }

    override func tearDown() async throws {
        try super.tearDownWithError()
        app.launchArguments.removeAll()
        app = nil
    }

    func testMakeScreenshots() {
        handleLocationAlert()
        handleNotificationAlert()
        checkMap()
        checkParks()
        checkEvents()
        checkProfile()
    }

    private func checkMap() {
        waitForServerResponse()
        snapshot("0-parksMap")
    }

    private func checkParks() {
        waitAndTapOrFail(timeout: 10, element: parksListPickerButton)
        waitForServerResponse()
        snapshot("1-parksList")

        waitAndTapOrFail(timeout: 10, element: firstParkCell)
        waitForServerResponse()
        snapshot("2-parkDetails")
        waitAndTapOrFail(timeout: 5, element: closeButton)
    }

    private func checkEvents() {
        waitAndTapOrFail(timeout: 10, element: eventsTabButton)
        waitAndTapOrFail(timeout: 10, element: pastEventsPickerButton)
        waitForServerResponse(10)
        snapshot("3-pastEvents")

        waitAndTapOrFail(timeout: 10, element: firstEventViewCell)
        waitForServerResponse(10)
        snapshot("4-eventDetails")
        waitAndTapOrFail(timeout: 5, element: closeButton)
    }

    private func checkProfile() {
        waitAndTapOrFail(timeout: 5, element: profileTabButton)
        waitAndTapOrFail(element: authorizeButton)
        waitAndTapOrFail(element: loginField)
        loginField.typeText(login)
        waitAndTapOrFail(element: passwordField)
        passwordField.typeText(password)
        waitAndTapOrFail(element: loginButton)
        handlePasswordAlert()
        waitAndTapOrFail(timeout: 10, element: searchUsersButton)
        waitAndTapOrFail(timeout: 10, element: searchUserField)
        sleep(1) // иногда симулятор начинает печатать раньше времени, поэтому ждем
        searchUserField.typeText(usernameForSearch)
        searchUserField.typeText("\n") // жмем "return", чтобы начать поиск
        waitAndTapOrFail(timeout: 10, element: firstFoundUserCell)
        waitForServerResponse()
        snapshot("5-profile")
    }
}

private extension WorkoutAppUITests {
    func handleLocationAlert() {
        let alert = springBoard.alerts.firstMatch
        let button = alert.buttons.element(
            matching: NSPredicate(
                format:
                "label IN {'Allow While Using App', 'При использовании приложения'}"
            )
        )
        waitAndTap(timeout: 5, element: button)
    }

    func handleNotificationAlert() {
        let alert = springBoard.alerts.firstMatch
        let button = alert.buttons.element(
            matching: NSPredicate(
                format:
                "label IN {'Allow', 'Разрешить'}"
            )
        )
        waitAndTap(timeout: 5, element: button)
    }

    func handlePasswordAlert() {
        let ruButton = app.buttons["Сохранить"].firstMatch
        let enButton = app.buttons["Save"].firstMatch
        let foundRuButton = waitAndTap(timeout: 5, element: ruButton)
        guard !foundRuButton else { return }
        waitAndTap(timeout: 5, element: enButton)
    }

    var tabbar: XCUIElement { app.tabBars.firstMatch }
    var parksListPickerButton: XCUIElement {
        app.segmentedControls.firstMatch.buttons.element(boundBy: 1)
    }

    var profileTabButton: XCUIElement { tabbar.buttons.element(boundBy: 3) }
    var eventsTabButton: XCUIElement { tabbar.buttons.element(boundBy: 1) }
    var authorizeButton: XCUIElement { app.buttons["authorizeButton"] }
    var loginField: XCUIElement {
        let id = "loginField"
        let oldElement = app.textViews[id]
        let modernElement = app.textFields[id]
        return oldElement.exists ? oldElement : modernElement
    }

    var passwordField: XCUIElement { app.secureTextFields["passwordField"] }
    var loginButton: XCUIElement { app.buttons["loginButton"] }
    var searchUsersButton: XCUIElement { app.buttons["searchUsersButton"] }
    var closeButton: XCUIElement { app.buttons["closeButton"] }
    var searchUserField: XCUIElement { app.searchFields.firstMatch }
    var firstFoundUserCell: XCUIElement { app.buttons["UserViewCell"].firstMatch }
    var firstParkCell: XCUIElement { app.buttons["ParkViewCell"].firstMatch }
    var pastEventsPickerButton: XCUIElement {
        app.segmentedControls.firstMatch.buttons.element(boundBy: 1)
    }

    var firstEventViewCell: XCUIElement { app.buttons["EventViewCell"].firstMatch }
}
