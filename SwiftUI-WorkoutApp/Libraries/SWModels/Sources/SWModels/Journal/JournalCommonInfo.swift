import Foundation

public struct JournalCommonInfo {
    public let authorId: Int?
    // `URL` картинки
    public let imageURL: URL?
    /// Заголовок отображаемой записи
    public let entryTitle: String
    /// Дата сообщения
    public let entryDateString: String
    /// Отформатированное сообщение
    public let formattedMessage: String

    public init(journalResponse: JournalResponse) {
        self.authorId = journalResponse.ownerId
        self.imageURL = journalResponse.imageURL
        self.entryTitle = journalResponse.title
        self.entryDateString = journalResponse.lastMessageDateString
        self.formattedMessage = journalResponse.formattedLastMessage
    }

    public init(journalEntryResponse: JournalEntryResponse) {
        self.authorId = journalEntryResponse.authorId
        self.imageURL = journalEntryResponse.imageURL
        self.entryTitle = journalEntryResponse.authorName ?? ""
        self.entryDateString = journalEntryResponse.messageDateString
        self.formattedMessage = journalEntryResponse.formattedMessage
    }
}
