@testable import ShortAddressService
import XCTest

final class ShortAddressServiceTests: XCTestCase {
    func testAddress() {
        let service = krasnodarService
        let address = service.address
        let expectedResult = "Россия, Краснодар"
        XCTAssertEqual(address, expectedResult)
    }

    func testCoordinates() {
        let service = krasnodarService
        let coordinates = service.coordinates
        let expectedResult = (45.04484, 38.97603)
        XCTAssertEqual(coordinates.0, expectedResult.0)
        XCTAssertEqual(coordinates.1, expectedResult.1)
    }

    func testCityName() {
        let service = krasnodarService
        let cityName = service.cityName
        let expectedResult = "Краснодар"
        XCTAssertEqual(cityName, expectedResult)
    }
}

private extension ShortAddressServiceTests {
    var krasnodarService: ShortAddressService { .init(17, 67) }
}
