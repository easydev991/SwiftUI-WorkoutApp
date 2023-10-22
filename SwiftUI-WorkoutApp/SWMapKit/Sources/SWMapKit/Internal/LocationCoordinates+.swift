extension LocationCoordinates {
    /// Установлены ли координаты локации
    var isSpecified: Bool {
        lat != 0 && lon != 0
    }
}
