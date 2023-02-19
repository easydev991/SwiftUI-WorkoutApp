import Foundation
import UIKit.UIImage

@MainActor
final class EventFormViewModel: ObservableObject {
    private var eventID: Int?
    private let oldEventForm: EventForm
    @Published var eventForm: EventForm
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var isEventSaved = false
    @Published var newImages = [UIImage]()

    /// Инициализирует viewModel для создания/изменения существующего мероприятия
    /// - Parameter event: вся информация о мероприятии
    init(with event: EventResponse? = nil) {
        self.eventID = event?.id
        self.eventForm = .init(event)
        self.oldEventForm = .init(event)
    }

    /// Инициализирует viewModel для создания нового мероприятия на выбранной площадке
    /// - Parameters:
    ///   - sportsGround: площадка для мероприятия
    init(with sportsGround: SportsGround) {
        self.oldEventForm = .emptyValue
        self.eventForm = .emptyValue
        eventForm.sportsGround = sportsGround
    }

    func deleteExtraImagesIfNeeded() {
        while imagesLimit < 0 {
            newImages.removeLast()
        }
    }

    func saveEvent(with defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        eventForm.newMediaFiles = newImages.toMediaFiles
        do {
            isEventSaved = try await APIService(with: defaults).saveEvent(id: eventID, form: eventForm).id != .zero
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    /// Не показываем пикер площадок, если `userID` отсутствует
    func canShowGroundPicker(with defaults: DefaultsProtocol) -> Bool {
        defaults.mainUserInfo?.userID != nil
    }

    func clearErrorMessage() { errorMessage = "" }
}

extension EventFormViewModel {
    var isFormReady: Bool {
        eventID == nil
            ? eventForm.isReadyToCreate
            : eventForm.isReadyToUpdate(old: oldEventForm) || !newImages.isEmpty
    }

    var imagesLimit: Int {
        eventID == nil
            ? Constants.photosLimit - newImages.count
            : Constants.photosLimit - newImages.count - eventForm.photosCount
    }

    var canAddImages: Bool {
        guard !isLoading else { return false }
        return eventID == nil
            ? newImages.count < Constants.photosLimit
            : (newImages.count + eventForm.photosCount) < Constants.photosLimit
    }
}
