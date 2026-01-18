@testable import SWModels
import Testing

struct ParkFormTests {
    @Test
    func isNotReadyToCreate_empty() {
        let form = emptyForm
        #expect(!form.isReadyToCreate)
    }

    @Test
    func isNotReadyToCreate_address() {
        let form1 = makeForm(address: "")
        let form2 = makeForm(address: " ")
        #expect(!form1.isReadyToCreate)
        #expect(!form2.isReadyToCreate)
    }

    @Test
    func isNotReadyToCreate_latitude() {
        let form = makeForm(latitude: "")
        #expect(!form.isReadyToCreate)
    }

    @Test
    func isNotReadyToCreate_longitude() {
        let form = makeForm(longitude: "")
        #expect(!form.isReadyToCreate)
    }

    @Test
    func isNotReadyToCreate_cityId() {
        let form = makeForm(cityId: 0)
        #expect(!form.isReadyToCreate)
    }

    @Test
    func isNotReadyToCreate_newMediaFiles() {
        let form = makeForm(newMediaFiles: [])
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
    func isNotReadyToUpdate_spaces() {
        let oldForm = makeForm(address: " ", latitude: " ", longitude: " ")
        let newForm = emptyForm
        #expect(!newForm.isReadyToUpdate(old: oldForm))
    }

    @Test
    func isNotReadyToUpdate_equal() {
        let oldForm = makeForm()
        let newForm = makeForm()
        #expect(!newForm.isReadyToUpdate(old: oldForm))
    }

    @Test
    func isReadyToUpdate_address() {
        let oldForm = makeForm(address: "old")
        let newForm = makeForm()
        #expect(newForm.isReadyToUpdate(old: oldForm))
    }

    @Test
    func isReadyToUpdate_latitude() {
        let oldForm = makeForm(latitude: "old")
        let newForm = makeForm()
        #expect(newForm.isReadyToUpdate(old: oldForm))
    }

    @Test
    func isReadyToUpdate_longitude() {
        let oldForm = makeForm(longitude: "old")
        let newForm = makeForm()
        #expect(newForm.isReadyToUpdate(old: oldForm))
    }

    @Test
    func isReadyToUpdate_cityId() {
        let oldForm = makeForm(cityId: 123)
        let newForm = makeForm()
        #expect(newForm.isReadyToUpdate(old: oldForm))
    }

    @Test
    func isReadyToUpdate_typeId() {
        let oldForm = makeForm(typeId: 123)
        let newForm = makeForm()
        #expect(newForm.isReadyToUpdate(old: oldForm))
    }

    @Test
    func isReadyToUpdate_sizeId() {
        let oldForm = makeForm(sizeId: 123)
        let newForm = makeForm()
        #expect(newForm.isReadyToUpdate(old: oldForm))
    }

    @Test
    func isReadyToUpdate_newMediaFiles() {
        let oldForm = makeForm()
        let newForm = makeForm(
            newMediaFiles: (2 ..< 4).map {
                MediaFile(imageData: .init(), forKey: "\($0)")
            }
        )
        #expect(newForm.isReadyToUpdate(old: oldForm))
    }
}

private extension ParkFormTests {
    var emptyForm: ParkForm { .init(.emptyValue) }

    func makeForm(
        address: String = "address",
        latitude: String = "latitude",
        longitude: String = "longitude",
        cityId: Int = 1,
        typeId: Int = 1,
        sizeId: Int = 1,
        photosCount _: Int = 1,
        newMediaFiles: [MediaFile] = [.init(imageData: .init(), forKey: "1")]
    ) -> ParkForm {
        let park = Park(
            id: 1,
            typeId: typeId,
            sizeId: sizeId,
            address: address,
            author: nil,
            cityId: cityId,
            commentsCount: nil,
            createDate: nil,
            latitude: latitude,
            longitude: longitude,
            name: "Название площадки",
            photosOptional: [.init(id: 1, stringURL: "demo")],
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
