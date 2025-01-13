import Foundation

public struct RequestComponents {
    let path: String
    let queryItems: [URLQueryItem]?
    let httpMethod: HTTPMethod
    public var headerFields: [HTTPHeaderField]
    let body: Data?
    /// Тип авторизации
    ///
    /// Если нужна авторизация, то будет добавлен хедер для авторизации
    public var needAuth: Bool

    /// Инициализатор
    /// - Parameters:
    ///   - path: Путь запроса
    ///   - queryItems: Параметры `query`
    ///   - httpMethod: Метод запроса
    ///   - headerFields: Параметры `header'a`
    ///   - body: Тело запроса
    ///   - needAuth: Нужна ли авторизация, по умолчанию `true`
    public init(
        path: String,
        queryItems: [URLQueryItem]? = nil,
        httpMethod: HTTPMethod,
        headerFields: [HTTPHeaderField] = [],
        body: Data? = nil,
        needAuth: Bool = true
    ) {
        self.path = path
        self.queryItems = queryItems
        self.httpMethod = httpMethod
        self.headerFields = headerFields
        self.body = body
        self.needAuth = needAuth
    }

    var url: URL? {
        let scheme = "https"
        let host = "workout.su/api/v3"
        let stringComponents = "\(scheme)://\(host)\(path)"
        var components = URLComponents(string: stringComponents)
        if let queryItems, !queryItems.isEmpty {
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
        request.allHTTPHeaderFields = Dictionary(uniqueKeysWithValues: headerFields.map { ($0.key, $0.value) })
        return request
    }
}
