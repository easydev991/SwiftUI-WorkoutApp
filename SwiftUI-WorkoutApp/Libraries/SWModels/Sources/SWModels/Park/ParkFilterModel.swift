import Foundation

public struct ParkFilterModel: Equatable {
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
