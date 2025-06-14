@testable import SWModels
import Testing

struct NoParksFoundModelTests {
    private typealias SUT = NoParksFoundModel

    @Test("Все условия выполнены - возвращает true")
    func allConditionsMet_returnsTrue() {
        let model = SUT(
            isFilterEdited: true,
            isFilteredParksEmpty: true,
            didParksManagerLoad: true,
            isLoading: false
        )
        #expect(model.showNoParksFound)
    }

    @Test("Список площадок не пустой - возвращает false")
    func parksNotEmpty_returnsFalse() {
        let model = SUT(
            isFilterEdited: true,
            isFilteredParksEmpty: false,
            didParksManagerLoad: true,
            isLoading: false
        )
        #expect(!model.showNoParksFound)
    }

    @Test("Менеджер не загрузился - возвращает false")
    func managerNotLoaded_returnsFalse() {
        let model = SUT(
            isFilterEdited: true,
            isFilteredParksEmpty: true,
            didParksManagerLoad: false,
            isLoading: false
        )
        #expect(!model.showNoParksFound)
    }

    @Test("Идет загрузка - возвращает false")
    func isLoading_returnsFalse() {
        let model = SUT(
            isFilterEdited: true,
            isFilteredParksEmpty: true,
            didParksManagerLoad: true,
            isLoading: true
        )
        #expect(!model.showNoParksFound)
    }

    @Test("Несколько условий не выполнены - возвращает false")
    func multipleFalseConditions_returnsFalse() {
        let model = SUT(
            isFilterEdited: false,
            isFilteredParksEmpty: false,
            didParksManagerLoad: false,
            isLoading: true
        )
        #expect(!model.showNoParksFound)
    }
}
