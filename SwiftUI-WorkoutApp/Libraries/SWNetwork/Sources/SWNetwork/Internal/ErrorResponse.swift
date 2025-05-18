import Foundation

struct ErrorResponse: Codable {
    let errors: [String]
    let name, message: String?
    let code, status: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.errors = try container.decodeIfPresent([String].self, forKey: .errors) ?? []
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        self.code = try container.decodeIfPresent(Int.self, forKey: .code) ?? 0
        self.status = try container.decodeIfPresent(Int.self, forKey: .status) ?? 0
    }

    init(
        errors: [String] = [],
        name: String? = nil,
        message: String? = nil,
        code: Int = 0,
        status: Int = 0
    ) {
        self.errors = errors
        self.name = name
        self.message = message
        self.code = code
        self.status = status
    }

    var realMessage: String? {
        if let message {
            message
        } else {
            errors.isEmpty ? nil : errors.joined(separator: ", ")
        }
    }

    func makeRealCode(statusCode: Int?) -> Int {
        let realCode = code != 0 ? code : status
        return realCode != 0 ? realCode : (statusCode ?? 0)
    }
}
