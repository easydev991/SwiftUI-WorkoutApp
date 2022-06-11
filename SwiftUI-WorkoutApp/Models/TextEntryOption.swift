import Foundation

enum TextEntryOption {
    /// Комментарий к площадке
    case ground(id: Int)
    /// Комментарий к мероприятию
    case event(id: Int)
    /// Запись в дневнике
    case journal(id: Int)
}
