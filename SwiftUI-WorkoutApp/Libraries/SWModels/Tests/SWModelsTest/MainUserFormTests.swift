import Foundation
@testable import SWModels
import Testing

struct MainUserFormTests {
    @Test
    func isNotReadyToRegister_empty() {
        let form = emptyForm
        #expect(!form.isReadyToRegister)
    }

    @Test
    func isNotReadyToRegister_userName() {
        let form = makeForm(userName: "")
        #expect(!form.isReadyToRegister)
    }

    @Test
    func isNotReadyToRegister_email() {
        let form = makeForm(email: "")
        #expect(!form.isReadyToRegister)
    }

    @Test
    func isNotReadyToRegister_passwordCount() {
        let form = makeForm(password: "short")
        #expect(!form.isReadyToRegister)
    }

    @Test
    func isNotReadyToRegister_gender() {
        let form = makeForm(gender: .unspecified)
        #expect(!form.isReadyToRegister)
    }

    @Test
    func isNotReadyToRegister_age() {
        let form = makeForm(birthDate: .now)
        #expect(!form.isReadyToRegister)
    }

    @Test
    func isReadyToRegister() {
        let form = makeForm()
        #expect(form.isReadyToRegister)
    }

    @Test
    func isNotReadyToSave_empty() {
        let oldForm = makeForm()
        let newForm = emptyForm
        #expect(!newForm.isReadyToSave(comparedTo: oldForm))
    }

    @Test
    func isNotReadyToSave_equal() {
        let oldForm = makeForm()
        let newForm = makeForm()
        #expect(!newForm.isReadyToSave(comparedTo: oldForm))
    }

    @Test
    func isNotReadyToSave_userName() {
        let oldForm = makeForm()
        let newForm = makeForm(userName: "")
        #expect(!newForm.isReadyToSave(comparedTo: oldForm))
    }

    @Test
    func isNotReadyToSave_email() {
        let oldForm = makeForm()
        let newForm = makeForm(email: "")
        #expect(!newForm.isReadyToSave(comparedTo: oldForm))
    }

    @Test
    func isNotReadyToSave_fullName() {
        let oldForm = makeForm()
        let newForm = makeForm(fullName: "")
        #expect(!newForm.isReadyToSave(comparedTo: oldForm))
    }

    @Test
    func isNotReadyToSave_gender() {
        let oldForm = makeForm()
        let newForm = makeForm(gender: .unspecified)
        #expect(!newForm.isReadyToSave(comparedTo: oldForm))
    }

    @Test
    func isNotReadyToSave_age() {
        let oldForm = makeForm()
        let newForm = makeForm(birthDate: .now)
        #expect(!newForm.isReadyToSave(comparedTo: oldForm))
    }

    @Test
    func isReadyToSave_userName() {
        let oldForm = makeForm(userName: "old")
        let newForm = makeForm()
        #expect(newForm.isReadyToSave(comparedTo: oldForm))
    }

    @Test
    func isReadyToSave_fullName() {
        let oldForm = makeForm(fullName: "old")
        let newForm = makeForm()
        #expect(newForm.isReadyToSave(comparedTo: oldForm))
    }

    @Test
    func isReadyToSave_email() {
        let oldForm = makeForm(email: "old@old.com")
        let newForm = makeForm()
        #expect(newForm.isReadyToSave(comparedTo: oldForm))
    }

    @Test
    func isReadyToSave_password() {
        let oldForm = makeForm(password: "oldPassword")
        let newForm = makeForm()
        #expect(newForm.isReadyToSave(comparedTo: oldForm))
    }

    @Test
    func isReadyToSave_birthDate() throws {
        let oldDate = try #require(Calendar.current.date(from: .init(year: 1980, month: 1, day: 1)))
        let oldForm = makeForm(birthDate: oldDate)
        let newForm = makeForm()
        #expect(newForm.isReadyToSave(comparedTo: oldForm))
    }

    @Test
    func isReadyToSave_country() {
        let oldForm = makeForm(country: .init(cities: [], id: "0", name: "0"))
        let newForm = makeForm()
        #expect(newForm.isReadyToSave(comparedTo: oldForm))
    }

    @Test
    func isReadyToSave_city() {
        let oldForm = makeForm(city: .init(id: "0"))
        let newForm = makeForm()
        #expect(newForm.isReadyToSave(comparedTo: oldForm))
    }

    @Test
    func isReadyToSave_gender() {
        let oldForm = makeForm(gender: .female)
        let newForm = makeForm()
        #expect(newForm.isReadyToSave(comparedTo: oldForm))
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
