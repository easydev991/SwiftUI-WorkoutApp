import Foundation
@testable import SWUtils
import Testing

struct SWFileManagerTests {
    private let uniqueFileName = "test_\(UUID().uuidString).json"

    @Test
    func getFromMissingFile_shouldThrowError() throws {
        let sut = SWFileManagerImp(fileName: uniqueFileName)
        try #require(!sut.documentExists)
        #expect(throws: Error.self) {
            let _: TestModel = try sut.get()
        }
    }

    @Test
    func saveAndRead_shouldWorkCorrectly() {
        let sut = SWFileManagerImp(fileName: uniqueFileName)
        #expect(!sut.documentExists)
        let testModel = TestModel(title: "Demo file")
        do {
            try sut.save(testModel)
            #expect(sut.documentExists, "Файл должен существовать")
            let savedModel: TestModel = try sut.get()
            #expect(testModel == savedModel, "Модели должны совпадать")
        } catch {
            Issue.record(error, "Файл должен сохраняться и читаться без ошибок")
        }
    }
}

extension SWFileManagerTests {
    private struct TestModel: Codable, Equatable {
        let title: String
    }
}
