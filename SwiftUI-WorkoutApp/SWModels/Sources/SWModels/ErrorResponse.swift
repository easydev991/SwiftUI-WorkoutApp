public struct ErrorResponse: Codable {
    public let errors: [String]?
    public let name, message: String?
    public let code, status: Int?
    public let type: String?

    public var realCode: Int {
        if let code, code != .zero {
            return code
        } else {
            return status.valueOrZero
        }
    }
}
