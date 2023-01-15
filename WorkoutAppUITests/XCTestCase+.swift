import XCTest

extension XCTestCase {
    @discardableResult
    func waitAndTap(timeout: TimeInterval, element: XCUIElement) -> Bool {
        let isElementFound = element.waitForExistence(timeout: timeout)
        if isElementFound { element.tapElement() }
        return isElementFound
    }

    func waitAndTapOrFail(timeout: TimeInterval = 3, element: XCUIElement) {
        if !waitAndTap(timeout: timeout, element: element) {
            XCTFail("Не нашли элемент \(element)")
        }
    }

    func waitAndPressOrFail(timeout: TimeInterval = 3, pressDuration: TimeInterval = 1.1, element: XCUIElement) {
        if element.waitForExistence(timeout: timeout) {
            element.press(forDuration: pressDuration)
        } else {
            XCTFail("Не нашли элемент \(element)")
        }
    }

    func swipeToFind(element: XCUIElement, in app: XCUIApplication, direction: SwipeDirection = .up) {
        while !element.isVisibleOnScreen {
            switch direction {
            case .up:
                app.swipeUp(velocity: .slow)
            case .down:
                app.swipeDown(velocity: .slow)
            case .left:
                app.swipeLeft(velocity: .slow)
            case .right:
                app.swipeRight(velocity: .slow)
            }
        }
        waitAndTapOrFail(element: element)
    }
}

extension XCTestCase {
    enum SwipeDirection {
        case up, down, left, right
    }
}
