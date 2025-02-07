@testable import SWNetwork
import Testing

struct StatusCodeGroupTests {
    @Test(arguments: [StatusCodeGroup.info, .redirect, .clientError, .serverError, .unknown])
    func isSuccess(notSuccessCode: StatusCodeGroup) {
        #expect(!notSuccessCode.isSuccess)
        #expect(StatusCodeGroup.success.isSuccess)
    }

    @Test(arguments: [StatusCodeGroup.success, .info, .redirect, .unknown])
    func isError(notErrorCode: StatusCodeGroup) {
        #expect(!notErrorCode.isError)
        #expect(StatusCodeGroup.clientError.isError)
        #expect(StatusCodeGroup.serverError.isError)
    }
}
