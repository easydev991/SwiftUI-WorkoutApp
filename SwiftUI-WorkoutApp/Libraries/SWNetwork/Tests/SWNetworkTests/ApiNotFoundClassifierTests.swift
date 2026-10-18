import Foundation
@testable import SWNetwork
import Testing

struct ApiNotFoundClassifierTests {
    @Test("Настоящий API-404 распознаётся по непустому errors")
    func apiErrorsBodyIsNotFound() {
        let data = Data(#"{"errors":["Площадка не найдена"]}"#.utf8)
        #expect(isApiNotFoundBody(data))
    }

    @Test("Настоящий API-404 распознаётся по name")
    func apiNameBodyIsNotFound() {
        let data = Data(#"{"name":"Not Found"}"#.utf8)
        #expect(isApiNotFoundBody(data))
    }

    @Test("HTML-страница 404 от nginx-прокси не считается настоящим API-404")
    func nginxHtmlBodyIsNotApiNotFound() {
        let data = Data("<!DOCTYPE html><html><head><title>404 Not Found</title></head><body>nginx</body></html>".utf8)
        #expect(isApiNotFoundBody(data) == false)
    }

    @Test("Пустой JSON-объект не считается настоящим API-404")
    func emptyJsonBodyIsNotApiNotFound() {
        let data = Data("{}".utf8)
        #expect(isApiNotFoundBody(data) == false)
    }

    @Test("Пустая строка в name считается настоящим API-404")
    func emptyNameBodyIsApiNotFound() {
        let data = Data(#"{"name":""}"#.utf8)
        #expect(isApiNotFoundBody(data))
    }

    @Test("Явный null в name не считается настоящим API-404")
    func nullNameBodyIsNotApiNotFound() {
        let data = Data(#"{"name":null}"#.utf8)
        #expect(isApiNotFoundBody(data) == false)
    }

    @Test("Пустой errors с null name и лишними полями сервера не считается настоящим API-404")
    func emptyErrorsNullNameFullEnvelopeIsNotApiNotFound() {
        let data = Data(#"{"errors":[],"name":null,"code":0,"status":0}"#.utf8)
        #expect(isApiNotFoundBody(data) == false)
    }

    @Test("У serverUnavailable есть непустой текст ошибки")
    func serverUnavailableHasErrorDescription() {
        let errorDescription = APIError.serverUnavailable.errorDescription
        #expect(errorDescription?.isEmpty == false)
    }
}
