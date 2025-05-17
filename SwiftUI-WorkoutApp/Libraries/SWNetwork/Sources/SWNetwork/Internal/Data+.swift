import Foundation

extension Data {
    var prettyJson: String {
        if let object = try? JSONSerialization.jsonObject(with: self, options: []),
           let jsonData = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
           let json = String(data: jsonData, encoding: .utf8) {
            json
        } else {
            "отсутствует"
        }
    }

    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
