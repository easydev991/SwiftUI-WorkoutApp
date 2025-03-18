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
        let monitor = NetworkMonitorActor()
        monitorTask = Task {
            for await status in monitor.updates {
                self.isConnected = status
            }
        }
    }

    private func startLegacyMonitoring() {
        let queue = DispatchQueue.global(qos: .background)
        legacyMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        legacyMonitor.start(queue: queue)
    }

    deinit {
        legacyMonitor.cancel()
        monitorTask?.cancel()
    }
}

@available(iOS 17.0, *)
private actor NetworkMonitorActor {
    private let monitor = NWPathMonitor()

    nonisolated var updates: AsyncStream<Bool> {
        AsyncStream { continuation in
            let handle = Task {
                await startMonitoring(continuation: continuation)
            }
            continuation.onTermination = { @Sendable _ in
                handle.cancel()
            }
        }
    }

    private func startMonitoring(continuation: AsyncStream<Bool>.Continuation) async {
        monitor.pathUpdateHandler = { path in
            continuation.yield(path.status == .satisfied)
        }
        monitor.start(queue: .global(qos: .background))
        await withTaskCancellationHandler {
            monitor.cancel()
            continuation.finish()
        } onCancel: {
            monitor.cancel()
            continuation.finish()
        }
    }
}
