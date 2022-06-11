import Foundation

struct ErrorResponse: Codable {
    let errors: [String]?
    let name, message: String?
    let code, status: Int?
    let type: String?

    var realCode: Int {
        if let code = code, code != .zero {
            return code
        } else {
            return status.valueOrZero
        }
    }
}
