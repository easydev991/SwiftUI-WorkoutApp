public struct NoParksFoundModel: Sendable {
    public let isFilterEdited: Bool
    let isFilteredParksEmpty: Bool
    let didParksManagerLoad: Bool
    let isLoading: Bool

    /// Инициализатор
    /// - Parameters:
    ///   - isFilterEdited: Настроил ли пользователь фильтр площадок
    ///   - isFilteredParksEmpty: Пустой ли список отфильтрованных площадок
    ///   - didParksManagerLoad: Загрузился ли менеджер площадок
    ///   - isLoading: Загружается ли что-то на экране
    public init(
        isFilterEdited: Bool,
        isFilteredParksEmpty: Bool,
        didParksManagerLoad: Bool,
        isLoading: Bool
    ) {
        self.isFilterEdited = isFilterEdited
        self.isFilteredParksEmpty = isFilteredParksEmpty
        self.didParksManagerLoad = didParksManagerLoad
        self.isLoading = isLoading
    }

    public var showNoParksFound: Bool {
        isFilteredParksEmpty && didParksManagerLoad && !isLoading
    }
}
