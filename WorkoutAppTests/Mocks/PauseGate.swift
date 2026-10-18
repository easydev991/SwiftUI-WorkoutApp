import Foundation

/// Гейт паузы для моков: блокирует первые `pauseFirstCalls` вызовов до `resumeAll()`
@MainActor
final class PauseGate {
    /// Сколько первых вызовов заблокировать до вызова `resumeAll()`
    var pauseFirstCalls = 0
    /// Одноразовый сигнал «мок заблокировался в паузе» — тест ждёт это событие вместо таймингов
    var onPaused: (@Sendable () -> Void)?
    private var pausedContinuations: [CheckedContinuation<Void, Never>] = []

    /// Снимает все паузы
    func resumeAll() {
        let continuations = pausedContinuations
        pausedContinuations = []
        continuations.forEach { $0.resume() }
    }

    /// Ждёт, если вызов попал в паузу; вызывать сразу после инкремента счётчика вызовов
    func waitIfPaused() async {
        guard pauseFirstCalls > 0 else { return }
        pauseFirstCalls -= 1
        await withCheckedContinuation { continuation in
            pausedContinuations.append(continuation)
            // Повторный resume() того же continuation - фатальная ошибка,
            // поэтому сигнал гасим после первого входа в паузу
            let handler = onPaused
            onPaused = nil
            handler?()
        }
    }
}
