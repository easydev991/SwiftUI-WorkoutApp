import Foundation
import Network

public final class NetworkStatus: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)

    @Published public private(set) var isConnected = false

    public init() {
        monitor.pathUpdateHandler = { [weak self] path in
            OperationQueue.main.addOperation {
                self?.isConnected = path.status == .satisfied ? true : false
            }
        }
        monitor.start(queue: queue)
    }
}
