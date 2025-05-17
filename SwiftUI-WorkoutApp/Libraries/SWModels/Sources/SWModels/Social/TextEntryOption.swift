public enum TextEntryOption: Sendable {
    /// Комментарий к площадке
    case park(id: Int)
    /// Комментарий к мероприятию
    case event(id: Int)
    /// Запись в дневнике
    ///
    /// - `ownerId` - `id` владельца дневника
    /// - `journalId` - `id` дневника
    case journal(ownerId: Int, journalId: Int)
}
