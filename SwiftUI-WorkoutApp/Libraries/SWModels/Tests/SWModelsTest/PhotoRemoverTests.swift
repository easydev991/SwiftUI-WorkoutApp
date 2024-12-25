@testable import SWModels
import Testing

struct PhotoRemoverTests {
    @Test
    func removesCorrectPhoto() {
        let photos = makeTestPhotos(count: 4)
        let removeId = 2
        let photoRemover = PhotoRemover(initialPhotos: photos, removeId: removeId)
        let expectedPhotos = [
            Photo(id: 1, stringURL: "http://example.com/photo1.jpg"),
            Photo(id: 2, stringURL: "http://example.com/photo3.jpg"),
            Photo(id: 3, stringURL: "http://example.com/photo4.jpg")
        ]
        #expect(photoRemover.photosAfterRemoval == expectedPhotos)
    }

    @Test
    func noPhotosRemoved_wrongId() {
        let photos = makeTestPhotos(count: 3)
        let removeId = 4
        let photoRemover = PhotoRemover(initialPhotos: photos, removeId: removeId)
        let expectedPhotos = [
            Photo(id: 1, stringURL: "http://example.com/photo1.jpg"),
            Photo(id: 2, stringURL: "http://example.com/photo2.jpg"),
            Photo(id: 3, stringURL: "http://example.com/photo3.jpg")
        ]
        #expect(photoRemover.photosAfterRemoval == expectedPhotos)
    }

    @Test
    func emptyPhotosBeforeAndAfter() {
        let photos = [Photo]()
        let removeId = 1
        let photoRemover = PhotoRemover(initialPhotos: photos, removeId: removeId)
        let expectedPhotos = [Photo]()
        #expect(photoRemover.photosAfterRemoval == expectedPhotos)
    }
}

private func makeTestPhotos(count: Int) -> [Photo] {
    Array(0 ..< count).map { id in
        let serverId = id + 1
        return Photo(id: serverId, stringURL: "http://example.com/photo\(serverId).jpg")
    }
}
