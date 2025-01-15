import Foundation

public struct RequestComponents {
    let path: String
    let queryItems: [URLQueryItem]
    let httpMethod: HTTPMethod
    public var headerFields: [HTTPHeaderField]
    let body: Data?
    /// Токен для авторизации
    public var token: String?

    /// Инициализатор
    /// - Parameters:
    ///   - path: Путь запроса
    ///   - queryItems: Параметры `query`, по умолчанию отсутствуют
    ///   - httpMethod: Метод запроса
    ///   - headerFields: Параметры хедеров, по умолчанию отсутствуют
    ///   - body: Тело запроса, по умолчанию `nil`
    ///   - token: Токен для авторизации, по умолчанию `nil`
    public init(
        path: String,
        queryItems: [URLQueryItem] = [],
        httpMethod: HTTPMethod,
        headerFields: [HTTPHeaderField] = [],
        body: Data? = nil,
        token: String? = nil
    ) {
        self.path = path
        self.queryItems = queryItems
        self.httpMethod = httpMethod
        self.headerFields = headerFields
        self.body = body
        self.token = token
    }

    var url: URL? {
        let scheme = "https"
        let host = "workout.su/api/v3"
        let stringComponents = "\(scheme)://\(host)\(path)"
        var components = URLComponents(string: stringComponents)
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        return components?.url
    }
}

extension RequestComponents {
    var urlRequest: URLRequest? {
        guard let url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body
        var allHeaders = headerFields
        if let token {
            allHeaders.append(.authorizationBasic(token))
        }
        request.allHTTPHeaderFields = Dictionary(uniqueKeysWithValues: allHeaders.map { ($0.key, $0.value) })
        return request
    }
}
