/// Модель "контейнера" для удаления фотографии
///
/// Используется для удаления фотографий площадок/мероприятий
public enum PhotoContainer: Sendable {
    case event(Input), park(Input)

    public struct Input: Sendable {
        public let containerId, photoId: Int

        public init(containerId: Int, photoId: Int) {
            self.containerId = containerId
            self.photoId = photoId
        }
    }
}
