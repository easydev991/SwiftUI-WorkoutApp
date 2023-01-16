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
