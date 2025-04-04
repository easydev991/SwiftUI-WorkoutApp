import Foundation

public struct JournalCommonInfo {
    public let authorID: Int?
    // `URL` картинки
    public let imageURL: URL?
    /// Заголовок отображаемой записи
    public let entryTitle: String
    /// Дата сообщения
    public let entryDateString: String
    /// Отформатированное сообщение
    public let formattedMessage: String

    public init(journalResponse: JournalResponse) {
        self.authorID = journalResponse.ownerID
        self.imageURL = journalResponse.imageURL
        self.entryTitle = journalResponse.title
        self.entryDateString = journalResponse.lastMessageDateString
        self.formattedMessage = journalResponse.formattedLastMessage
    }

    public init(journalEntryResponse: JournalEntryResponse) {
        self.authorID = journalEntryResponse.authorID
        self.imageURL = journalEntryResponse.imageURL
        self.entryTitle = journalEntryResponse.authorName ?? ""
        self.entryDateString = journalEntryResponse.messageDateString
        self.formattedMessage = journalEntryResponse.formattedMessage
    }
}
