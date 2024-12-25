@testable import SWNetwork
import Testing

struct APIErrorTests {
    @Test
    func badRequest() {
        let error = APIError(with: 400)
        #expect(error == .badRequest)
    }

    @Test
    func invalidCredentials() {
        let error = APIError(with: 401)
        #expect(error == .invalidCredentials)
    }

    @Test
    func notFound() {
        let error = APIError(with: 404)
        #expect(error == .notFound)
    }

    @Test
    func payloadTooLarge() {
        let error = APIError(with: 413)
        #expect(error == .payloadTooLarge)
    }

    @Test
    func serverError() {
        let error = APIError(with: 500)
        #expect(error == .serverError)
    }

    @Test
    func customErrorWithMessage() {
        let errorResponse = ErrorResponse(
            errors: nil,
            name: nil,
            message: "Непредвиденная ошибка",
            code: nil,
            status: nil,
            type: nil
        )
        let error = APIError(errorResponse, 123)
        #expect(error.errorDescription == "123, Непредвиденная ошибка")
    }

    @Test
    func customErrorWithErrorsArray() {
        let errorResponse = ErrorResponse(errors: ["Ошибка 1", "Ошибка 2"], name: nil, message: nil, code: nil, status: nil, type: nil)
        let error = APIError(errorResponse, nil)
        #expect(error.errorDescription == "404, Ошибка 1,\nОшибка 2")
    }

    @Test
    func unknownError() {
        let errorResponse = ErrorResponse(errors: nil, name: nil, message: nil, code: nil, status: nil, type: nil)
        let error = APIError(errorResponse, nil)
        #expect(error == .unknown)
    }
}
