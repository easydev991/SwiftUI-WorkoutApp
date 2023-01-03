import Foundation
import UIKit.UIImage

@MainActor
final class EventFormViewModel: ObservableObject {
    @Published var eventInfo: EventForm
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var isSuccess = false
    @Published var newImages = [UIImage]()
    private var eventID: Int?
    var imagesLimit: Int {
        eventID == nil
        ? Constants.photosLimit - newImages.count
        : Constants.photosLimit - newImages.count - eventInfo.photosCount
    }
    var canAddImages: Bool {
        guard !isLoading else { return false }
        return eventID == nil
        ? newImages.count < Constants.photosLimit
        : (newImages.count + eventInfo.photosCount) < Constants.photosLimit
    }

    init(with event: EventResponse? = nil) {
        eventID = event?.id
        eventInfo = .init(event)
    }

    init(with sportsGround: SportsGround) {
        eventInfo = .emptyValue
        eventInfo.sportsGround = sportsGround
    }

    func saveEvent(with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        eventInfo.newImagesData = newImages.enumerated().map {
            .init(withImage: $0.element, forKey: ($0.offset + 1).description)
        }
        do {
            isSuccess = try await APIService(with: defaults).saveEvent(id: eventID, form: eventInfo).id != .zero
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}
