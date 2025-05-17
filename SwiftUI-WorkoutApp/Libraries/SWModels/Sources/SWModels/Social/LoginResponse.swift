public struct LoginResponse: Codable {
    public let userID: Int

    public enum CodingKeys: String, CodingKey { case userID = "user_id" }
}
