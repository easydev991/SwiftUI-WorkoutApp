import XCTest

extension XCUIElement {
    func tapElement() {
        if isHittable {
            tap()
        } else {
            coordinate(withNormalizedOffset: .init(dx: 0.0, dy: 0.0)).tap()
        }
    }

    var isVisibleOnScreen: Bool {
        exists && isHittable
    }
}

extension XCTestCase {
    @MainActor
    @discardableResult
    func waitAndTap(timeout: TimeInterval, element: XCUIElement) -> Bool {
        let isElementFound = element.waitForExistence(timeout: timeout)
        if isElementFound { element.tapElement() }
        return isElementFound
    }

    @MainActor
    func waitAndTapOrFail(timeout: TimeInterval = 3, element: XCUIElement) {
        if !waitAndTap(timeout: timeout, element: element) {
            XCTFail("Не нашли элемент \(element)")
        }
    }

    @MainActor
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

    /// Иногда сервер очень долго отвечает, или картинки долго грузятся, поэтому ждем
    func waitForServerResponse(_ timeout: UInt32 = 5) {
        sleep(timeout)
    }

    /// Свайп вниз для закрытия модального окна
    @MainActor
    func swipeDownToClosePage(element: XCUIElement) {
        let start = element.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let finish = element.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 30))
        start.press(forDuration: 0.5, thenDragTo: finish)
    }
}

extension XCTestCase {
    enum SwipeDirection {
        case up, down, left, right
    }
}
