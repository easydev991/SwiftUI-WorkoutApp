import Foundation
import Network

@MainActor
public final class NetworkStatus: ObservableObject {
    @Published public private(set) var isConnected = false
    @Published public private(set) var isStatusInitialized = false
    private let monitor = NWPathMonitor()

    public init() {
        if #available(iOS 17.0, *) {
            setupModernMonitoring()
        } else {
            setupLegacyMonitoring()
        }
        monitor.start(queue: .global(qos: .background))
    }

    @available(iOS 17.0, *)
    private func setupModernMonitoring() {
        Task {
            for await path in monitor {
                await MainActor.run {
                    self.isConnected = path.status == .satisfied
                    if !self.isStatusInitialized {
                        self.isStatusInitialized = true
                    }
                }
            }
        }
    }

    private func setupLegacyMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                if let self, !self.isStatusInitialized {
                    self.isStatusInitialized = true
                }
            }
        }
    }

    deinit {
        monitor.cancel()
    }
}
