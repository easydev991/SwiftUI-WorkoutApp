enum StatusCodeGroup {
    case info
    case success
    case redirect
    case clientError
    case serverError
    case unknown

    init(code: Int) {
        switch code {
        case 100 ... 199: self = .info
        case 200 ... 299: self = .success
        case 300 ... 399: self = .redirect
        case 400 ... 499: self = .clientError
        case 500 ... 599: self = .serverError
        default: self = .unknown
        }
    }

    var isError: Bool {
        switch self {
        case .clientError, .serverError: true
        default: false
        }
    }

    var isSuccess: Bool { self == .success }
}
