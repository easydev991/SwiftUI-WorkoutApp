import Foundation
import Network

public final class NetworkStatus: ObservableObject, @unchecked Sendable {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)

    /// `true` - there is a network connection, `false` - no network connection
    @Published public private(set) var isConnected = false

    public init() {
        monitor.pathUpdateHandler = { path in
            Task { @MainActor in
                self.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}
