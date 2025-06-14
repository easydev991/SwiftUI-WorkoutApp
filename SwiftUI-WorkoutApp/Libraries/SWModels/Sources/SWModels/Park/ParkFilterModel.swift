import Foundation

public struct ParkFilterModel: Equatable, Codable, RawRepresentable {
    /// Размеры площадок
    public var size: [ParkSize]
    /// Типы/классы площадок
    public var grade: [ParkGrade]

    public init(
        size: [ParkSize] = ParkSize.allCases,
        grade: [ParkGrade] = ParkGrade.allCases
    ) {
        self.size = size
        self.grade = grade
    }

    /// Влияет на возможность сбросить фильтры и на цвет иконки в навбаре
    public var isEdited: Bool {
        self != .init()
    }

    public static func == (lhs: ParkFilterModel, rhs: ParkFilterModel) -> Bool {
        lhs.isEqual(to: rhs)
    }

    func isEqual(to other: ParkFilterModel) -> Bool {
        // Сравниваем массивы без учета порядка, проверяя содержимое
        Set(size) == Set(other.size) && Set(grade) == Set(other.grade)
    }
}

// MARK: - RawRepresentable

public extension ParkFilterModel {
    init?(rawValue: String) {
        let components = rawValue.split(separator: "|")
        guard components.count == 2 else { return nil }

        // Парсим размеры
        let sizeStrings = components[0].split(separator: ",")
        let sizes = sizeStrings.compactMap { Int($0).flatMap { ParkSize(rawValue: $0) } }
        // Проверяем, что все размеры получены и их количество корректное
        guard sizes.count == sizeStrings.count, !sizes.isEmpty else { return nil }

        // Парсим типы
        let gradeStrings = components[1].split(separator: ",")
        let grades = gradeStrings.compactMap { Int($0).flatMap { ParkGrade(rawValue: $0) } }
        // Проверяем, что все типы получены и их количество корректное
        guard grades.count == gradeStrings.count, !grades.isEmpty else { return nil }

        self.size = sizes
        self.grade = grades
    }

    var rawValue: String {
        let sizeString = size.map { String($0.rawValue) }.joined(separator: ",")
        let gradeString = grade.map { String($0.rawValue) }.joined(separator: ",")
        return "\(sizeString)|\(gradeString)"
    }
}
