import Foundation

public struct RequestComponents {
    let path: String
    let queryItems: [URLQueryItem]
    let httpMethod: HTTPMethod
    let hasMultipartFormData: Bool
    let body: Data?
    let token: String?

    /// Инициализатор
    /// - Parameters:
    ///   - path: Путь запроса
    ///   - queryItems: Параметры `query`, по умолчанию отсутствуют
    ///   - httpMethod: Метод запроса
    ///   - hasMultipartFormData: Есть ли в запросе файлы для отправки (в нашем случае картинки), по умолчанию `false`
    ///   - body: Тело запроса, по умолчанию `nil`
    ///   - token: Токен для авторизации, по умолчанию `nil`
    public init(
        path: String,
        queryItems: [URLQueryItem] = [],
        httpMethod: HTTPMethod,
        hasMultipartFormData: Bool = false,
        body: Data? = nil,
        token: String? = nil
    ) {
        self.path = path
        self.queryItems = queryItems
        self.httpMethod = httpMethod
        self.hasMultipartFormData = hasMultipartFormData
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
        var allHeaders = [HTTPHeaderField]()
        // TODO: генерировать boundary в одном месте (вместо FFF)
        if let body {
            allHeaders.append(.init(key: "Content-Length", value: "\(body.count)"))
        }
        if hasMultipartFormData {
            allHeaders.append(.init(key: "Content-Type", value: "multipart/form-data; boundary=FFF"))
        }
        if let token {
            allHeaders.append(.init(key: "Authorization", value: "Basic \(token)"))
        }
        request.allHTTPHeaderFields = Dictionary(uniqueKeysWithValues: allHeaders.map { ($0.key, $0.value) })
        return request
    }
}
