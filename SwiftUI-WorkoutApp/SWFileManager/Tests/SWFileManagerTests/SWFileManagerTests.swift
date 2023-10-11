@testable import SWFileManager
import XCTest

final class SWFileManagerTests: XCTestCase {
    private struct TestModel: Codable, Equatable {
        let title, subtitle: String
        let items: [Int]
    }

    func testFailToDelete() {
        let manager = SWFileManager(fileName: "RandomFile.json")
        XCTAssertThrowsError(try manager.removeFile(), "Нельзя удалить файл, которого не существует")
    }

    func testAllFeaturesSuccess() {
        let manager = SWFileManager(fileName: "TestFile.json")
        let testModel = TestModel(
            title: "File name",
            subtitle: "Test description",
            items: [1, 2, 3, 4]
        )
        do {
            try manager.save(testModel)
            XCTAssertTrue(manager.documentExists, "Файл должен существовать")
            let savedModel: TestModel = try manager.get()
            XCTAssertEqual(testModel, savedModel, "Модели должны совпадать")
            try manager.removeFile()
            XCTAssertFalse(manager.documentExists, "Файл должен быть удален")
        } catch {
            XCTFail("Файл должен сохраняться, читаться и удаляться без ошибок")
        }
    }
}
