public struct HTTPHeaderField: Equatable {
    let key: String
    let value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }

    public static func authorizationBasic(_ token: String?) -> HTTPHeaderField {
        .init(key: "Authorization", value: "Basic \(token ?? "")")
    }
}
