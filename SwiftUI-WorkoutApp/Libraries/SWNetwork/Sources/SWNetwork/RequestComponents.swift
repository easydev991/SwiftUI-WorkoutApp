import Foundation

public struct RequestComponents {
    let path: String
    let queryItems: [URLQueryItem]
    let httpMethod: HTTPMethod
    let hasMultipartFormData: Bool
    let body: (parameters: [String: String], mediaFiles: [BodyMaker.MediaFile]?)?
    let boundary: String
    let token: String?

    /// Инициализатор
    /// - Parameters:
    ///   - path: Путь запроса
    ///   - queryItems: Параметры `query`, по умолчанию отсутствуют
    ///   - httpMethod: Метод запроса
    ///   - hasMultipartFormData: Есть ли в запросе файлы для отправки (в нашем случае картинки), по умолчанию `false`
    ///   - body: Данные для тела запроса, по умолчанию `nil`
    ///   - boundary: `Boundary` для `body`, по умолчанию `UUID().uuidString`
    ///   - token: Токен для авторизации, по умолчанию `nil`
    public init(
        path: String,
        queryItems: [URLQueryItem] = [],
        httpMethod: HTTPMethod,
        hasMultipartFormData: Bool = false,
        body: (parameters: [String: String], mediaFiles: [BodyMaker.MediaFile]?)? = nil,
        boundary: String = UUID().uuidString,
        token: String? = nil
    ) {
        self.path = path
        self.queryItems = queryItems
        self.httpMethod = httpMethod
        self.hasMultipartFormData = hasMultipartFormData
        self.body = body
        self.boundary = boundary
        self.token = token
    }

    var url: URL? {
        let scheme = "https"
        let host = "workout.su/api/v3"
        guard path.starts(with: "/") else { return nil }
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

        var allHeaders = [HTTPHeaderField]()
        var httpBodyData: Data?

        if let body {
            let parameters = body.parameters.map(BodyMaker.Parameter.init)
            if hasMultipartFormData {
                httpBodyData = BodyMaker.makeBodyWithMultipartForm(
                    parameters: parameters,
                    media: body.mediaFiles,
                    boundary: boundary
                )
                allHeaders.append(.init(
                    key: "Content-Type",
                    value: "multipart/form-data; boundary=\(boundary)"
                ))
            } else {
                httpBodyData = BodyMaker.makeBody(with: parameters)
            }
            if let httpBodyData {
                allHeaders.append(.init(key: "Content-Length", value: "\(httpBodyData.count)"))
            }
        }

        if let token, !token.isEmpty {
            allHeaders.append(.init(key: "Authorization", value: "Basic \(token)"))
        }
        request.allHTTPHeaderFields = Dictionary(
            uniqueKeysWithValues: allHeaders.map { ($0.key, $0.value) }
        )
        request.httpBody = httpBodyData
        return request
    }
}
