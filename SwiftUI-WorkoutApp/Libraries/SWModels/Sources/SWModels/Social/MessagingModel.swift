/// Модель для отправки сообщения
public struct MessagingModel {
    /// Получатель сообщения
    public var recipient: UserResponse?
    /// Статус отправки сообщения
    public var isLoading: Bool
    /// Текст сообщения
    public var message: String
    /// Можно ли отправить сообщение
    public var canSendMessage: Bool { !message.isEmpty && !isLoading }

    /// Инициализатор
    /// - Parameters:
    ///   - recipient: Получатель сообщения
    ///   - isLoading: Статус отправки сообщения
    ///   - message: Текст сообщения
    public init(
        recipient: UserResponse? = nil,
        isLoading: Bool = false,
        message: String = ""
    ) {
        self.recipient = recipient
        self.isLoading = isLoading
        self.message = message
    }
}
