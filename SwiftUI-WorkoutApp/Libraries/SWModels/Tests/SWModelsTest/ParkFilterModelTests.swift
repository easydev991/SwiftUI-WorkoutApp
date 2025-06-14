@testable import SWModels
import Testing

struct ParkFilterModelTests {
    private typealias SUT = ParkFilterModel

    @Test("Инициализация с дефолтными значениями")
    func initWithDefaultValues() {
        let model = SUT()
        #expect(model.size == ParkSize.allCases, "Размеры должны быть инициализированы всеми значениями ParkSize")
        #expect(model.grade == ParkGrade.allCases, "Типы должны быть инициализированы всеми значениями ParkGrade")
        #expect(!model.isEdited, "Модель с дефолтными значениями не должна считаться отредактированной")
    }

    @Test("Инициализация с пользовательскими значениями")
    func initWithCustomValues() {
        let customSizes = [ParkSize.small, .large]
        let customGrades = [ParkGrade.modern]
        let model = SUT(size: customSizes, grade: customGrades)
        #expect(model.size == customSizes, "Размеры должны соответствовать переданным значениям")
        #expect(model.grade == customGrades, "Типы должны соответствовать переданным значениям")
        #expect(model.isEdited, "Модель с пользовательскими значениями должна считаться отредактированной")
    }

    @Test("Свойство isEdited при дефолтных и измененных значениях")
    func isEditedProperty() {
        let defaultModel = SUT()
        let editedModel = SUT(size: [.medium], grade: ParkGrade.allCases)
        let editedGradeModel = SUT(size: ParkSize.allCases, grade: [.soviet])
        #expect(!defaultModel.isEdited, "Дефолтная модель не должна считаться отредактированной")
        #expect(editedModel.isEdited, "Модель с измененными размерами должна считаться отредактированной")
        #expect(editedGradeModel.isEdited, "Модель с измененными типами должна считаться отредактированной")
    }

    @Test("Сравнение моделей с одинаковым содержимым в разном порядке")
    func equalityWithDifferentOrder() {
        let model1 = SUT(size: [.small, .large], grade: [.soviet, .modern])
        let model2 = SUT(size: [.large, .small], grade: [.modern, .soviet])
        #expect(model1 == model2, "Модели с одинаковым содержимым, но разным порядком должны считаться равными")
        #expect(model1.isEqual(to: model2), "Метод isEqual должен возвращать true для одинакового содержимого")
    }

    @Test("Сравнение моделей с разным содержимым")
    func inequalityWithDifferentContent() {
        let model1 = SUT(size: [.small], grade: [.soviet, .collars])
        let model2 = SUT(size: [.small, .medium], grade: [.soviet])
        #expect(model1 != model2, "Модели с разным содержимым должны считаться неравными")
        #expect(!model1.isEqual(to: model2), "Метод isEqual должен возвращать false для разного содержимого")
    }

    @Test("Сравнение дефолтной модели с измененной")
    func compareDefaultAndEdited() {
        let defaultModel = SUT()
        let editedModel = SUT(size: [.small], grade: ParkGrade.allCases)
        #expect(defaultModel != editedModel, "Дефолтная и измененная модели должны считаться разными")
        #expect(!defaultModel.isEqual(to: editedModel), "Метод isEqual должен возвращать false для дефолтной и измененной моделей")
    }

    @Test("Инициализация из валидного rawValue")
    func initFromValidRawValue() throws {
        let rawValue = "1,2,3|1,2,3,6"
        let expectedModel = SUT(size: [.small, .medium, .large], grade: [.soviet, .modern, .collars, .legendary])

        let model = try #require(SUT(rawValue: rawValue))
        #expect(model.size == expectedModel.size, "Размеры должны соответствовать значениям из rawValue")
        #expect(model.grade == expectedModel.grade, "Типы должны соответствовать значениям из rawValue")
    }

    @Test(
        "Инициализация из невалидного rawValue",
        arguments: [
            "", // пустая строка
            "|", // пустые массивы
            "\(ParkSize.small.rawValue)", // нет разделителя для grade
            "\(ParkSize.small.rawValue)|0,\(ParkGrade.soviet.rawValue),4,5,7", // grade 0, 4, 5, 7 не существует
            "0,4,\(ParkSize.small.rawValue)|\(ParkGrade.soviet.rawValue)" // size 0 и 4 не существует
        ]
    )
    func initFromInvalidRawValue(string: String) {
        let model = SUT(rawValue: string)
        #expect(model == nil)
    }

    @Test("Преобразование в rawValue")
    func rawValueConversion() {
        let model = SUT(size: [.small, .large], grade: [.soviet, .collars])
        let expectedRawValue = "1,3|1,3"
        #expect(model.rawValue == expectedRawValue)
    }

    @Test("Циклическое преобразование Model -> RawValue -> Model")
    func roundTripConversion() throws {
        let originalModel = SUT(size: [.medium, .large], grade: [.modern, .collars])
        let rawValue = originalModel.rawValue
        let convertedModel = try #require(SUT(rawValue: rawValue))
        #expect(convertedModel.size == originalModel.size, "Размеры должны остаться неизменными после циклического преобразования")
        #expect(convertedModel.grade == originalModel.grade, "Типы должны остаться неизменными после циклического преобразования")
    }
}
