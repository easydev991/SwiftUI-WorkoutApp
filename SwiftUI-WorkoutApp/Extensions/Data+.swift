import Foundation

extension Data {
    var prettyJson: String {
        do {
            let object = try JSONSerialization.jsonObject(with: self, options: [.fragmentsAllowed])
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
            let json = String(data: jsonData, encoding: .utf8)
            return json.valueOrEmpty
        } catch {
            print("--- Не удалось вывести в JSON: \(error)")
        }
        return ""
    }

    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
