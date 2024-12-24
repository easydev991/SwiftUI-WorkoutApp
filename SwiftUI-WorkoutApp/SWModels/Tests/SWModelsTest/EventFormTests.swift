import Foundation
@testable import SWModels
import Testing

struct EventFormTests {
    @Test
    func isNotReadyToCreate_empty() {
        let form = emptyForm
        #expect(!form.isReadyToCreate)
    }

    @Test
    func isNotReadyToCreate_title() {
        let form = makeForm(title: "")
        #expect(!form.isReadyToCreate)
    }

    @Test
    func isNotReadyToCreate_description() {
        let form = makeForm(description: "")
        #expect(!form.isReadyToCreate)
    }

    @Test
    func isNotReadyToCreate_parkID() {
        let form = makeForm(parkID: 0)
        #expect(!form.isReadyToCreate)
    }

    @Test
    func isReadyToCreate() {
        let form = makeForm()
        #expect(form.isReadyToCreate)
    }

    @Test
    func isNotReadyToUpdate_empty() {
        let oldForm = makeForm()
        let newForm = emptyForm
        #expect(!newForm.isReadyToUpdate(old: oldForm))
    }

    @Test
    func isNotReadyToUpdate_title() {
        let oldForm = makeForm()
        let newForm = makeForm(title: "")
        #expect(!newForm.isReadyToUpdate(old: oldForm))
    }

    @Test
    func isNotReadyToUpdate_description() {
        let oldForm = makeForm()
        let newForm = makeForm(description: "")
        #expect(!newForm.isReadyToUpdate(old: oldForm))
    }

    @Test
    func isNotReadyToUpdate_equal() {
        let now = Date.now
        let oldForm = makeForm(date: now)
        let newForm = makeForm(date: now)
        #expect(!newForm.isReadyToUpdate(old: oldForm))
    }

    @Test
    func isReadyToUpdate_title() {
        let oldForm = makeForm(title: "old")
        let newForm = makeForm()
        #expect(newForm.isReadyToUpdate(old: oldForm))
    }

    @Test
    func isReadyToUpdate_description() {
        let oldForm = makeForm(description: "old")
        let newForm = makeForm()
        #expect(newForm.isReadyToUpdate(old: oldForm))
    }

    @Test
    func isReadyToUpdate_date() throws {
        let oldDate = try #require(Calendar.current.date(from: .init(year: 2023, month: 12, day: 22)))
        let oldForm = makeForm(date: oldDate)
        let newForm = makeForm()
        #expect(newForm.isReadyToUpdate(old: oldForm))
    }

    @Test
    func isReadyToUpdate_parkID() {
        let oldForm = makeForm(parkID: 123)
        let newForm = makeForm()
        #expect(newForm.isReadyToUpdate(old: oldForm))
    }

    @Test
    func isReadyToUpdate_parkName() {
        let oldForm = makeForm(parkName: "old")
        let newForm = makeForm()
        #expect(newForm.isReadyToUpdate(old: oldForm))
    }

    @Test
    func isReadyToUpdate_newMediaFiles() {
        let oldForm = makeForm()
        let newForm = makeForm(
            newMediaFiles: [.init(imageData: .init(), forKey: "1")]
        )
        #expect(newForm.isReadyToUpdate(old: oldForm))
    }
}

private extension EventFormTests {
    var emptyForm: EventForm { .init(.emptyValue) }

    func makeForm(
        title: String = "title",
        description: String = "description",
        date: Date = .now,
        parkID: Int = 1,
        parkName: String = "Площадка № 1",
        photosCount: Int = 0,
        newMediaFiles: [MediaFile] = []
    ) -> EventForm {
        .init(
            title: title,
            description: description,
            date: date,
            parkID: parkID,
            parkName: parkName,
            photosCount: photosCount,
            newMediaFiles: newMediaFiles
        )
    }
}
