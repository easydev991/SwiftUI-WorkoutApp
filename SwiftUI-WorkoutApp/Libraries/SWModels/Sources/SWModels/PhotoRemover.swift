import Foundation

/// Удаляет фото по идентификатору и составляет актуальный список фото
struct PhotoRemover {
    private let initialPhotos: [Photo]
    private let removeId: Int

    /// Инициализатор
    /// - Parameters:
    ///   - initialPhotos: Первоначальный массив фотографий
    ///   - removeId: Идентификатор фотографии для удаления
    init(initialPhotos: [Photo], removeId: Int) {
        self.initialPhotos = initialPhotos
        self.removeId = removeId
    }

    /// Актуальный список фотографий после процедуры удаления
    ///
    /// На сервере идентификаторы фотографий начинаются с цифры `1`,
    /// при изменении набора фотографий их идентификаторы тоже обновляются
    var photosAfterRemoval: [Photo] {
        initialPhotos
            .filter { $0.serverId != removeId }
            .enumerated()
            .map { index, photo in
                Photo(id: index + 1, stringURL: photo.stringURL)
            }
    }
}
