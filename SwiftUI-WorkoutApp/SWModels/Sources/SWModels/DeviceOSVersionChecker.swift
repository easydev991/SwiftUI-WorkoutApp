import Foundation

@available(
    iOS,
    introduced: 15,
    deprecated: 16,
    message: "refreshable работает в ScrollView на iOS 16, можно убрать неактуальную кнопку обновления"
)
public enum DeviceOSVersionChecker {
    /// Установлена ли iOS 16 на девайсе
    ///
    /// До iOS 16 `ScrollView` не поддерживает `refreshable`
    public static var iOS16Available: Bool {
        if #available(iOS 16, *) {
            true
        } else {
            false
        }
    }
}
