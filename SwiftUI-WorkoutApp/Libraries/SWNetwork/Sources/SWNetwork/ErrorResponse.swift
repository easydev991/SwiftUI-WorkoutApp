import Foundation

struct ErrorResponse: Codable {
    let errors: [String]?
    let name, message: String?
    let code, status: Int?

    var realCode: Int {
        if let code, code != 0 {
            code
        } else {
            status ?? 0
        }
    }
}
