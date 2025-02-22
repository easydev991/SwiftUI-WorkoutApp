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
        checkParks()
        checkEvents()
        checkProfile()
    }

    private func checkParks() {
        waitForServerResponse()
        waitAndTapOrFail(timeout: 10, element: parksListPickerButton)
        waitForServerResponse()
        snapshot("1-sportsGroundsList")

        waitAndTapOrFail(timeout: 10, element: firstParkCell)
        waitForServerResponse()
        snapshot("2-sportsGroundDetails")
        waitAndTapOrFail(timeout: 5, element: closeButton)
    }

    private func checkEvents() {
        waitAndTapOrFail(timeout: 10, element: eventsTabButton)
        waitAndTapOrFail(timeout: 10, element: pastEventsPickerButton)
        waitForServerResponse()
        snapshot("3-pastEvents")

        waitAndTapOrFail(timeout: 10, element: firstEventViewCell)
        waitForServerResponse()
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

    var tabbar: XCUIElement { app.tabBars.firstMatch }
    var parksListPickerButton: XCUIElement {
        app.segmentedControls.firstMatch.buttons.element(for: "Список")
    }

    var profileTabButton: XCUIElement { tabbar.buttons.element(for: "Профиль") }
    var eventsTabButton: XCUIElement { tabbar.buttons.element(for: "Мероприятия") }
    var authorizeButton: XCUIElement { app.buttons["authorizeButton"] }
    var loginField: XCUIElement { app.textFields["loginField"] }
    var passwordField: XCUIElement { app.secureTextFields["passwordField"] }
    var loginButton: XCUIElement { app.buttons["loginButton"] }
    var searchUsersButton: XCUIElement { app.buttons["searchUsersButton"] }
    var closeButton: XCUIElement { app.buttons["closeButton"] }
    var searchUserField: XCUIElement { app.searchFields.firstMatch }
    var firstFoundUserCell: XCUIElement { app.buttons["UserViewCell"].firstMatch }
    var firstParkCell: XCUIElement { app.buttons["ParkViewCell"].firstMatch }
    var pastEventsPickerButton: XCUIElement {
        app.segmentedControls.firstMatch.buttons.element(for: "Прошедшие")
    }

    var firstEventViewCell: XCUIElement { app.buttons["EventViewCell"].firstMatch }
}
