import Foundation

public extension KeyedDecodingContainer {
    /// Декодирует опциональное значение Int из строки или числа
    /// - Parameter key: Ключ для декодирования
    /// - Returns: Опциональное значение Int, или nil если ключ отсутствует или значение не может быть конвертировано
    func decodeIntOrStringIfPresent(_ key: Key) -> Int? {
        if let stringValue = try? decodeIfPresent(String.self, forKey: key),
           let intValue = Int(stringValue) {
            return intValue
        } else if let intValue = try? decodeIfPresent(Int.self, forKey: key) {
            return intValue
        }
        return nil
    }

    /// Декодирует обязательное значение Int из строки или числа
    /// - Parameter key: Ключ для декодирования
    /// - Returns: Значение Int
    /// - Throws: DecodingError если значение отсутствует или не может быть конвертировано
    func decodeIntOrString(_ key: Key) throws -> Int {
        if let idString = try? decodeIfPresent(String.self, forKey: key),
           let idInt = Int(idString) {
            return idInt
        } else if let idInt = try? decodeIfPresent(Int.self, forKey: key) {
            return idInt
        } else {
            throw DecodingError.typeMismatch(Int.self, DecodingError.Context(
                codingPath: codingPath + [key],
                debugDescription: "Ожидали Int или String для конвертации в Int"
            ))
        }
    }
}
