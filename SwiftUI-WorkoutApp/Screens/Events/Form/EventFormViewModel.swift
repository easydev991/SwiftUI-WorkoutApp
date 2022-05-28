import Foundation
import UIKit.UIImage

final class EventFormViewModel: ObservableObject {
    @Published var eventInfo: EventForm
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var isSuccess = false
    @Published var newImages = [UIImage]() {
        didSet { addNewImagesToForm() }
    }
    private var eventID: Int?
    var canAddImages: Bool {
        (eventInfo.photosCount + newImages.count) < Constants.photosLimit
        && !isLoading
    }

    init(with event: EventResponse? = nil) {
        eventID = event?.id
        eventInfo = .init(event)
    }

    init(with sportsGround: SportsGround) {
        eventInfo = .emptyValue
        eventInfo.sportsGround = sportsGround
    }

    @MainActor
    func saveEvent(with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            isSuccess = try await APIService(with: defaults).saveEvent(eventInfo, eventID: eventID).id != .zero
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

private extension EventFormViewModel {
    func addNewImagesToForm() {
        eventInfo.newImagesData = newImages.enumerated().map {
            .init(withImage: $0.element, forKey: ($0.offset + 1).description)
        }
    }
}
