import Foundation

public extension Data {
    var prettyJson: String {
        if let object = try? JSONSerialization.jsonObject(with: self, options: [.fragmentsAllowed]),
           let jsonData = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
           let json = String(data: jsonData, encoding: .utf8) {
            json
        } else {
            ""
        }
    }

    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
