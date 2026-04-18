import Foundation
import UIKit.UIDevice

/// Модель для общей обратной связи
public enum CommonFeedback {
    private static var processInfo: ProcessInfo {
        ProcessInfo.processInfo
    }

    public static let subject = "\(processInfo.processName): Обратная связь"

    public static let body = """
    \(CommonFeedback.sysVersion)
    \(CommonFeedback.appVersion)
    ---
    \(CommonFeedback.question)
    \n
    """
    private static let question = String(localized: .feedbackCommonQuestion)
    static var sysVersion: String {
        var platformName: String {
            let idiom = switch UIDevice.current.userInterfaceIdiom {
            case .pad: "iPadOS"
            default: "iOS"
            }
            return processInfo.isiOSAppOnMac ? "macOS" : idiom
        }
        return "\(platformName): \(processInfo.operatingSystemVersionString)"
    }

    static let appVersion = "Версия приложения: \(Constants.appVersion)"
}
