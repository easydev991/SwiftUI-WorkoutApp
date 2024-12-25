import Foundation

/// Жалоба
public enum Complaint {
    private static let subjectFirstPart = "\(ProcessInfo.processInfo.processName): Жалоба на "

    case eventPhoto(eventTitle: String)
    case eventComment(eventTitle: String, author: String, commentText: String)
    case parkPhoto(parkTitle: String)
    case parkComment(parkTitle: String, author: String, commentText: String)
    case journalEntry(author: String, entryText: String)

    public var subject: String {
        switch self {
        case .eventPhoto:
            Complaint.subjectFirstPart + "фото к мероприятию"
        case .eventComment:
            Complaint.subjectFirstPart + "комментарий к мероприятию"
        case .parkPhoto:
            Complaint.subjectFirstPart + "фото к площадке"
        case .parkComment:
            Complaint.subjectFirstPart + "комментарий к площадке"
        case .journalEntry:
            Complaint.subjectFirstPart + "запись в дневнике"
        }
    }

    public var body: String {
        switch self {
        case let .eventPhoto(eventTitle):
            "Наименование мероприятия: \(eventTitle)"
        case let .eventComment(eventTitle, author, commentText):
            """
            - Наименование мероприятия: \(eventTitle)
            - Автор комментария: \(author)
            - Текст комментария: \(commentText)
            """
        case let .parkPhoto(parkTitle):
            "Наименование площадки: \(parkTitle)"
        case let .parkComment(parkTitle, author, commentText):
            """
            - Наименование площадки: \(parkTitle)
            - Автор комментария: \(author)
            - Текст комментария: \(commentText)
            """
        case let .journalEntry(author, entryText):
            """
            Автор записи: \(author)
            Текст записи: \(entryText)
            """
        }
    }
}
