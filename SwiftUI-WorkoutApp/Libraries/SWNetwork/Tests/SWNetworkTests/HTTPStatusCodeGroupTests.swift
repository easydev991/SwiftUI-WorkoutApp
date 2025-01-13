@testable import SWNetwork
import Testing

struct StatusCodeGroupTests {
    @Test
    func isSuccess() {
        let notSuccessCodes: [StatusCodeGroup] = [
            .info, .redirect, .clientError, .serverError, .unknown
        ]
        notSuccessCodes.forEach { #expect(!$0.isSuccess) }
        #expect(StatusCodeGroup.success.isSuccess)
    }

    @Test
    func isError() {
        let notErrorCodes: [StatusCodeGroup] = [
            .success, .info, .redirect, .unknown
        ]
        notErrorCodes.forEach { #expect(!$0.isError) }
        #expect(StatusCodeGroup.clientError.isError)
        #expect(StatusCodeGroup.serverError.isError)
    }
}
