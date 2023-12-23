@testable import SWModels
import XCTest

final class EventFormTests: XCTestCase {
    func testIsNotReadyToCreate_empty() {
        let form = emptyForm
        XCTAssertFalse(form.isReadyToCreate)
    }

    func testIsNotReadyToCreate_title() {
        let form = makeForm(title: "")
        XCTAssertFalse(form.isReadyToCreate)
    }

    func testIsNotReadyToCreate_description() {
        let form = makeForm(description: "")
        XCTAssertFalse(form.isReadyToCreate)
    }

    func testIsNotReadyToCreate_sportsGroundID() {
        let form = makeForm(sportsGroundID: 0)
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

    func testIsNotReadyToUpdate_title() {
        let oldForm = makeForm()
        let newForm = makeForm(title: "")
        XCTAssertFalse(newForm.isReadyToUpdate(old: oldForm))
    }

    func testIsNotReadyToUpdate_description() {
        let oldForm = makeForm()
        let newForm = makeForm(description: "")
        XCTAssertFalse(newForm.isReadyToUpdate(old: oldForm))
    }

    func testIsNotReadyToUpdate_equal() {
        let now = Date.now
        let oldForm = makeForm(date: now)
        let newForm = makeForm(date: now)
        XCTAssertFalse(newForm.isReadyToUpdate(old: oldForm))
    }

    func testIsReadyToUpdate_title() {
        let oldForm = makeForm(title: "old")
        let newForm = makeForm()
        XCTAssertTrue(newForm.isReadyToUpdate(old: oldForm))
    }

    func testIsReadyToUpdate_description() {
        let oldForm = makeForm(description: "old")
        let newForm = makeForm()
        XCTAssertTrue(newForm.isReadyToUpdate(old: oldForm))
    }

    func testIsReadyToUpdate_date() {
        let oldDate = Calendar.current.date(
            from: .init(year: 2023, month: 12, day: 22)
        )
        let oldForm = makeForm(date: oldDate!)
        let newForm = makeForm()
        XCTAssertTrue(newForm.isReadyToUpdate(old: oldForm))
    }

    func testIsReadyToUpdate_sportsGroundID() {
        let oldForm = makeForm(sportsGroundID: 123)
        let newForm = makeForm()
        XCTAssertTrue(newForm.isReadyToUpdate(old: oldForm))
    }

    func testIsReadyToUpdate_sportsGroundName() {
        let oldForm = makeForm(sportsGroundName: "old")
        let newForm = makeForm()
        XCTAssertTrue(newForm.isReadyToUpdate(old: oldForm))
    }

    func testIsReadyToUpdate_newMediaFiles() {
        let oldForm = makeForm()
        let newForm = makeForm(
            newMediaFiles: [.init(imageData: .init(), forKey: "1")]
        )
        XCTAssertTrue(newForm.isReadyToUpdate(old: oldForm))
    }
}

private extension EventFormTests {
    var emptyForm: EventForm { .init(.emptyValue) }

    func makeForm(
        title: String = "title",
        description: String = "description",
        date: Date = .now,
        sportsGroundID: Int = 1,
        sportsGroundName: String = "Площадка № 1",
        photosCount: Int = 0,
        newMediaFiles: [MediaFile] = []
    ) -> EventForm {
        .init(
            title: title,
            description: description,
            date: date,
            sportsGroundID: sportsGroundID,
            sportsGroundName: sportsGroundName,
            photosCount: photosCount,
            newMediaFiles: newMediaFiles
        )
    }
}
