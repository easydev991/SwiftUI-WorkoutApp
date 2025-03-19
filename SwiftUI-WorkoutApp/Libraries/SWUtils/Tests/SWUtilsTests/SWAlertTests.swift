import Foundation
@testable import SWUtils
import Testing

@MainActor
struct SWAlertTests {
    @Test
    func noConnection_showAlert() {
        let isConnected = false
        let showAlert = SWAlert.shared.presentNoConnection(isConnected)
        #expect(showAlert, "Если нет подключения, нужно показать алерт")
    }

    @Test
    func noConnection_doNotShowAlert() {
        let isConnected = true
        let showAlert = SWAlert.shared.presentNoConnection(isConnected)
        #expect(!showAlert, "Если подключение есть, алерт показывать не нужно")
    }
}
