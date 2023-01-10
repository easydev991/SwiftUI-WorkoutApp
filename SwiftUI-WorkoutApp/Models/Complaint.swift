import Foundation

/// Жалоба
enum Complaint {
    private static let subjectFirstPart = "\(ProcessInfo.processInfo.processName): Жалоба на "

    case eventPhoto(eventTitle: String)
    case eventComment(eventTitle: String, author: String, commentText: String)
    case groundPhoto(groundTitle: String)
    case groundComment(groundTitle: String, author: String, commentText: String)
    case journalEntry(author: String, entryText: String)

    var subject: String {
        switch self {
        case .eventPhoto:
            return Complaint.subjectFirstPart + "фото к мероприятию"
        case .eventComment:
            return Complaint.subjectFirstPart + "комментарий к мероприятию"
        case .groundPhoto:
            return Complaint.subjectFirstPart + "фото к площадке"
        case .groundComment:
            return Complaint.subjectFirstPart + "комментарий к площадке"
        case .journalEntry:
            return Complaint.subjectFirstPart + "запись в дневнике"
        }
    }

    var body: String {
        switch self {
        case let .eventPhoto(eventTitle):
            return "Наименование мероприятия: \(eventTitle)"
        case let .eventComment(eventTitle, author, commentText):
            return """
            - Наименование мероприятия: \(eventTitle)
            - Автор комментария: \(author)
            - Текст комментария: \(commentText)
            """
        case let .groundPhoto(groundTitle):
            return "Наименование площадки: \(groundTitle)"
        case let .groundComment(groundTitle, author, commentText):
            return """
            - Наименование площадки: \(groundTitle)
            - Автор комментария: \(author)
            - Текст комментария: \(commentText)
            """
        case let .journalEntry(author, entryText):
            return """
            Автор записи: \(author)
            Текст записи: \(entryText)
            """
        }
    }
}
