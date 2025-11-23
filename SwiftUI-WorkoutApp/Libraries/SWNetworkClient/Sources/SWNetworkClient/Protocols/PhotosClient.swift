import Foundation
import SWModels

/// Протокол для управления фотографиями
public protocol PhotosClient: Sendable {
    /// Удаляет фотографию
    /// - Parameter container: контейнер с информацией о фотографии
    func deletePhoto(from container: PhotoContainer) async throws
}

extension SWClient: PhotosClient {
    public func deletePhoto(from container: PhotoContainer) async throws {
        let endpoint: Endpoint = switch container {
        case let .event(input):
            .deleteEventPhoto(
                eventId: input.containerId,
                photoId: input.photoId
            )
        case let .park(input):
            .deleteParkPhoto(
                parkId: input.containerId,
                photoId: input.photoId
            )
        }
        try await makeStatus(for: endpoint)
    }
}
