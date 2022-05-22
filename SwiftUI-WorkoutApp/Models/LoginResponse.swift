import Foundation

struct LoginResponse: Codable {
    let userID: Int

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
    }
}
