import Foundation
import Network

@MainActor
public final class NetworkStatus: ObservableObject {
    @Published private var isConnected = false
    @Published private(set) var isInitialized = false
    private let monitor = NWPathMonitor()

    /// `true` - есть подключение, `false` - нет подключения
    /// Если статус не инициализирован, возвращает `true` (предполагается наличие подключения)
    public var isOnline: Bool {
        isInitialized ? isConnected : true
    }

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
                    if !self.isInitialized {
                        self.isInitialized = true
                    }
                }
            }
        }
    }

    private func setupLegacyMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                if let self, !self.isInitialized {
                    self.isInitialized = true
                }
            }
        }
    }

    deinit {
        monitor.cancel()
    }
}
