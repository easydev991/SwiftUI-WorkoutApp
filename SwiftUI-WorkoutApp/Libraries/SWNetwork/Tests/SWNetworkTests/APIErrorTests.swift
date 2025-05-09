@testable import SWNetwork
import Testing

struct APIErrorTests {
    private static var badRequestCodes: [Int] {
        [400, 402, 403] + Array(405 ... 412) + Array(414 ... 499)
    }

    private static let serverErrorCodes = Array(500 ... 599)

    @Test(arguments: badRequestCodes)
    func badRequest(code: Int) {
        let error = APIError(with: code)
        #expect(error == .badRequest)
    }

    @Test(arguments: serverErrorCodes)
    func serverError(code: Int) {
        let error = APIError(with: code)
        #expect(error == .serverError)
    }

    @Test
    func errorInitializationByCode() {
        let testCases: [(Int?, APIError)] = [
            (401, .invalidCredentials),
            (404, .notFound),
            (413, .payloadTooLarge),
            (nil, .unknown),
            (999, .unknown)
        ]
        for (code, expected) in testCases {
            let error = APIError(with: code)
            #expect(error == expected)
        }
    }

    @Test
    func customErrorWithMessage() {
        let errorResponse = ErrorResponse(
            message: "Непредвиденная ошибка",
            code: 0,
            status: 0
        )
        let error = APIError(errorResponse, 123)
        #expect(error.errorDescription == "123, Непредвиденная ошибка")
    }

    @Test
    func customErrorWithErrorsArray() {
        let errorResponse = ErrorResponse(errors: ["Ошибка 1", "Ошибка 2"], code: 0, status: 0)
        let error = APIError(errorResponse, nil)
        #expect(error.errorDescription == "0, Ошибка 1, Ошибка 2")
    }

    @Test
    func unknownError() {
        let errorResponse = ErrorResponse(code: 0, status: 0)
        let error = APIError(errorResponse, nil)
        #expect(error == .unknown)
    }

    @Test
    func customErrorPriorities() {
        // Сообщение имеет приоритет над errors
        let case1 = ErrorResponse(
            errors: ["Error1", "Error2"],
            message: "Priority Message",
            code: 400,
            status: 0
        )
        let error1 = APIError(case1, nil)
        #expect(error1.errorDescription == "400, Priority Message")

        // Errors используются, если message отсутствует
        let case2 = ErrorResponse(
            errors: ["Error1", "Error2"],
            code: 0,
            status: 500
        )
        let error2 = APIError(case2, nil)
        #expect(error2.errorDescription == "500, Error1, Error2")
    }

    @Test
    func specialCombinations() {
        // Кастомная ошибка с кодом, соответствующим стандартному
        let response1 = ErrorResponse(message: "Custom Credentials", code: 401, status: 0)
        let error1 = APIError(response1, nil)
        #expect(error1 == .customError(code: 401, message: "Custom Credentials"))

        // Пустой массив errors
        let response2 = ErrorResponse(errors: [], code: 500, status: 0)
        let error2 = APIError(response2, nil)
        #expect(error2 == .serverError)
    }
}
