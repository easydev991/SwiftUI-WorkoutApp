@testable import SWModels
import XCTest

final class ParkFormTests: XCTestCase {
    func testIsNotReadyToCreate_empty() {
        let form = emptyForm
        XCTAssertFalse(form.isReadyToCreate)
    }

    func testIsNotReadyToCreate_address() {
        let form = makeForm(address: "")
        XCTAssertFalse(form.isReadyToCreate)
    }

    func testIsNotReadyToCreate_latitude() {
        let form = makeForm(latitude: "")
        XCTAssertFalse(form.isReadyToCreate)
    }

    func testIsNotReadyToCreate_longitude() {
        let form = makeForm(longitude: "")
        XCTAssertFalse(form.isReadyToCreate)
    }

    func testIsNotReadyToCreate_cityID() {
        let form = makeForm(cityID: 0)
        XCTAssertFalse(form.isReadyToCreate)
    }

    func testIsNotReadyToCreate_newMediaFiles() {
        let form = makeForm(newMediaFiles: [])
        XCTAssertFalse(form.isReadyToCreate)
    }

    func testIsReadyToCreate() {
        let form = makeForm()
        XCTAssertTrue(form.isReadyToCreate)
    }

    func testIsNotReadyToUpdate_empty() {
        let oldForm = makeForm()
        let newForm = emptyForm
        XCTAssertFalse(newForm.isReadyToUpdate(old: oldForm))
    }

    func testIsNotReadyToUpdate_equal() {
        let oldForm = makeForm()
        let newForm = makeForm()
        XCTAssertFalse(newForm.isReadyToUpdate(old: oldForm))
    }

    func testIsReadyToUpdate_address() {
        let oldForm = makeForm(address: "old")
        let newForm = makeForm()
        XCTAssertTrue(newForm.isReadyToUpdate(old: oldForm))
    }

    func testIsReadyToUpdate_latitude() {
        let oldForm = makeForm(latitude: "old")
        let newForm = makeForm()
        XCTAssertTrue(newForm.isReadyToUpdate(old: oldForm))
    }

    func testIsReadyToUpdate_longitude() {
        let oldForm = makeForm(longitude: "old")
        let newForm = makeForm()
        XCTAssertTrue(newForm.isReadyToUpdate(old: oldForm))
    }

    func testIsReadyToUpdate_cityID() {
        let oldForm = makeForm(cityID: 123)
        let newForm = makeForm()
        XCTAssertTrue(newForm.isReadyToUpdate(old: oldForm))
    }

    func testIsReadyToUpdate_typeID() {
        let oldForm = makeForm(typeID: 123)
        let newForm = makeForm()
        XCTAssertTrue(newForm.isReadyToUpdate(old: oldForm))
    }

    func testIsReadyToUpdate_sizeID() {
        let oldForm = makeForm(sizeID: 123)
        let newForm = makeForm()
        XCTAssertTrue(newForm.isReadyToUpdate(old: oldForm))
    }

    func testIsReadyToUpdate_newMediaFiles() {
        let oldForm = makeForm()
        let newForm = makeForm(
            newMediaFiles: (2 ..< 4).map {
                MediaFile(imageData: .init(), forKey: "\($0)")
            }
        )
        XCTAssertTrue(newForm.isReadyToUpdate(old: oldForm))
    }
}

private extension ParkFormTests {
    var emptyForm: ParkForm { .init(.emptyValue) }

    func makeForm(
        address: String = "address",
        latitude: String = "latitude",
        longitude: String = "longitude",
        cityID: Int = 1,
        typeID: Int = 1,
        sizeID: Int = 1,
        photosCount _: Int = 1,
        newMediaFiles: [MediaFile] = [.init(imageData: .init(), forKey: "1")]
    ) -> ParkForm {
        let park = Park(
            id: 1,
            typeID: typeID,
            sizeID: sizeID,
            address: address,
            author: nil,
            cityID: cityID,
            commentsCount: nil,
            countryID: 1,
            createDate: nil,
            modifyDate: nil,
            latitude: latitude,
            longitude: longitude,
            name: "Название площадки",
            photosOptional: [.init(id: 1)],
            preview: nil,
            usersTrainHereCount: 1,
            commentsOptional: nil,
            usersTrainHere: nil,
            trainHere: nil
        )
        var form = ParkForm(park)
        form.newMediaFiles = newMediaFiles
        return form
    }
}
