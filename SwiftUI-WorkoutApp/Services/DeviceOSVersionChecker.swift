import Foundation

@available(
    iOS,
    introduced: 15,
    deprecated: 16,
    message: "refreshable работает в ScrollView на iOS 16, можно убрать неактуальную кнопку обновления"
)
enum DeviceOSVersionChecker {
    /// Установлена ли iOS 16 на девайсе
    ///
    /// До iOS 16 `ScrollView` не поддерживает `refreshable`
    static var iOS16Available: Bool {
        if #available(iOS 16, *) {
            return true
        } else {
            return false
        }
    }
}
