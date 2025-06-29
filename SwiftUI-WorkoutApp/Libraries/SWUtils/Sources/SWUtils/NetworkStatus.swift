import Foundation
import Network

@MainActor
public final class NetworkStatus: ObservableObject {
    @Published public private(set) var isConnected = false
    private let legacyMonitor = NWPathMonitor()
    private var monitorTask: Task<Void, Never>?

    public init() {
        if #available(iOS 17.0, *) {
            startModernMonitoring()
        } else {
            startLegacyMonitoring()
        }
    }

    @available(iOS 17.0, *)
    private func startModernMonitoring() {
        let monitor = NWPathMonitor()
        monitorTask = Task {
            for await path in monitor {
                await MainActor.run {
                    self.isConnected = path.status == .satisfied
                }
            }
        }
        monitor.start(queue: .global(qos: .background))
    }

    private func startLegacyMonitoring() {
        legacyMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        legacyMonitor.start(queue: .global(qos: .background))
    }

    deinit {
        legacyMonitor.cancel()
        monitorTask?.cancel()
    }
}
