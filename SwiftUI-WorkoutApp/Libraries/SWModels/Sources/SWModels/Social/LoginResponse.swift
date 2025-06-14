public struct LoginResponse: Codable {
    public let userId: Int

    public enum CodingKeys: String, CodingKey { case userId = "user_id" }
}
