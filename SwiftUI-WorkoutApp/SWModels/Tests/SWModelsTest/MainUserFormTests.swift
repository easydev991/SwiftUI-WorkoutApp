@testable import SWModels
import XCTest

final class MainUserFormTests: XCTestCase {
    func testIsNotReadyToRegister_empty() {
        let form = emptyForm
        XCTAssertFalse(form.isReadyToRegister)
    }

    func testIsNotReadyToRegister_userName() {
        let form = makeForm(userName: "")
        XCTAssertFalse(form.isReadyToRegister)
    }

    func testIsNotReadyToRegister_email() {
        let form = makeForm(email: "")
        XCTAssertFalse(form.isReadyToRegister)
    }

    func testIsNotReadyToRegister_passwordCount() {
        let form = makeForm(password: "short")
        XCTAssertFalse(form.isReadyToRegister)
    }

    func testIsNotReadyToRegister_gender() {
        let form = makeForm(gender: .unspecified)
        XCTAssertFalse(form.isReadyToRegister)
    }

    func testIsNotReadyToRegister_age() {
        let form = makeForm(birthDate: .now)
        XCTAssertFalse(form.isReadyToRegister)
    }

    func testIsReadyToRegister() {
        let form = makeForm()
        XCTAssertTrue(form.isReadyToRegister)
    }

    func testIsNotReadyToSave_empty() {
        let oldForm = makeForm()
        let newForm = emptyForm
        XCTAssertFalse(newForm.isReadyToSave(comparedTo: oldForm))
    }

    func testIsNotReadyToSave_equal() {
        let oldForm = makeForm()
        let newForm = makeForm()
        XCTAssertFalse(newForm.isReadyToSave(comparedTo: oldForm))
    }

    func testIsNotReadyToSave_userName() {
        let oldForm = makeForm()
        let newForm = makeForm(userName: "")
        XCTAssertFalse(newForm.isReadyToSave(comparedTo: oldForm))
    }

    func testIsNotReadyToSave_email() {
        let oldForm = makeForm()
        let newForm = makeForm(email: "")
        XCTAssertFalse(newForm.isReadyToSave(comparedTo: oldForm))
    }

    func testIsNotReadyToSave_fullName() {
        let oldForm = makeForm()
        let newForm = makeForm(fullName: "")
        XCTAssertFalse(newForm.isReadyToSave(comparedTo: oldForm))
    }

    func testIsNotReadyToSave_gender() {
        let oldForm = makeForm()
        let newForm = makeForm(gender: .unspecified)
        XCTAssertFalse(newForm.isReadyToSave(comparedTo: oldForm))
    }

    func testIsNotReadyToSave_age() {
        let oldForm = makeForm()
        let newForm = makeForm(birthDate: .now)
        XCTAssertFalse(newForm.isReadyToSave(comparedTo: oldForm))
    }

    func testIsReadyToSave_userName() {
        let oldForm = makeForm(userName: "old")
        let newForm = makeForm()
        XCTAssertTrue(newForm.isReadyToSave(comparedTo: oldForm))
    }

    func testIsReadyToSave_fullName() {
        let oldForm = makeForm(fullName: "old")
        let newForm = makeForm()
        XCTAssertTrue(newForm.isReadyToSave(comparedTo: oldForm))
    }

    func testIsReadyToSave_email() {
        let oldForm = makeForm(email: "old@old.com")
        let newForm = makeForm()
        XCTAssertTrue(newForm.isReadyToSave(comparedTo: oldForm))
    }

    func testIsReadyToSave_password() {
        let oldForm = makeForm(password: "oldPassword")
        let newForm = makeForm()
        XCTAssertTrue(newForm.isReadyToSave(comparedTo: oldForm))
    }

    func testIsReadyToSave_birthDate() {
        let oldDate = Calendar.current.date(
            from: .init(year: 1980, month: 1, day: 1)
        )
        let oldForm = makeForm(birthDate: oldDate!)
        let newForm = makeForm()
        XCTAssertTrue(newForm.isReadyToSave(comparedTo: oldForm))
    }

    func testIsReadyToSave_country() {
        let oldForm = makeForm(country: .init(cities: [], id: "0", name: "0"))
        let newForm = makeForm()
        XCTAssertTrue(newForm.isReadyToSave(comparedTo: oldForm))
    }

    func testIsReadyToSave_city() {
        let oldForm = makeForm(city: .init(id: "0"))
        let newForm = makeForm()
        XCTAssertTrue(newForm.isReadyToSave(comparedTo: oldForm))
    }

    func testIsReadyToSave_gender() {
        let oldForm = makeForm(gender: .female)
        let newForm = makeForm()
        XCTAssertTrue(newForm.isReadyToSave(comparedTo: oldForm))
    }
}

private extension MainUserFormTests {
    var emptyForm: MainUserForm { .init(.emptyValue) }

    func makeForm(
        userName: String = "userName",
        fullName: String = "Full name",
        email: String = "email@email.com",
        password: String = "goodPassword123",
        birthDate: Date = Constants.minUserAge,
        country: Country = .defaultCountry,
        city: City = .defaultCity,
        gender: Gender = .male
    ) -> MainUserForm {
        .init(
            userName: userName,
            fullName: fullName,
            email: email,
            password: password,
            birthDate: birthDate,
            gender: gender.code,
            country: country,
            city: city
        )
    }
}
