import Foundation
import Network
@testable import SWUtils
import Testing

@MainActor
struct NetworkStatusTests {
    @Test("Должен устанавливать isStatusInitialized в false при инициализации")
    func initialIsStatusInitializedShouldBeFalse() {
        let networkStatus = NetworkStatus()
        #expect(!networkStatus.isStatusInitialized)
    }
}
