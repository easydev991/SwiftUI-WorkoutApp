import Foundation
import Network

final class CheckNetworkService: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)

    @Published var isConnected = false

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            OperationQueue.main.addOperation {
                self?.isConnected = path.status == .satisfied ? true : false
            }
        }
        monitor.start(queue: queue)
    }
}
