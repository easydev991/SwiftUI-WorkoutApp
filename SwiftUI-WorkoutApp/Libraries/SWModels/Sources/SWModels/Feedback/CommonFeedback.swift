import Foundation

/// Модель для общей обратной связи
public enum CommonFeedback {
    public static let subject = "\(ProcessInfo.processInfo.processName): Обратная связь"

    public static let body = """
        \(CommonFeedback.sysVersion)
        \(CommonFeedback.appVersion)
        \(CommonFeedback.question)
        \n
    """
    private static let question = String(localized: .feedbackCommonQuestion)
    static let sysVersion = "iOS: \(ProcessInfo.processInfo.operatingSystemVersionString)"
    static let appVersion = "App version: \(Constants.appVersion)"
}
