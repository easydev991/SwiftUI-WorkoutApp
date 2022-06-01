import Foundation
import UIKit.UIImage

@MainActor
final class SportsGroundFormViewModel: ObservableObject {
    @Published var groundForm: SportsGroundForm
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var isSuccess = false
    @Published var newImages = [UIImage]() {
        didSet { addNewImagesToForm() }
    }
    private var groundID: Int?
    var isFormReady: Bool {
        groundID == nil
        ? groundForm.isReadyToCreate
        : groundForm.isReadyToSend
    }
    var canAddImages: Bool {
        (groundForm.photosCount + newImages.count) < Constants.photosLimit
        && !isLoading
    }
    var isNewSportsGround: Bool {
        groundID == nil
    }

    /// Инициализирует viewModel для изменения существующей площадки
    /// - Parameter ground: вся информация о площадке
    init(with ground: SportsGround) {
        groundForm = .init(ground)
        groundID = ground.id
    }

    /// Инициализирует viewModel для создания новой площадки
    /// - Parameters:
    ///   - address: адрес текущего местоположения
    ///   - latitude: широта текущего местоположения
    ///   - longitude: долгота текущего местоположения
    ///   - cityID: `id` города пользователя
    init(
        _ address: String,
        _ latitude: Double,
        _ longitude: Double,
        _ cityID: Int
    ) {
        groundForm = .init(
            address: address,
            latitude: latitude,
            longitude: longitude,
            cityID: cityID
        )
    }

    func saveGround(with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            isSuccess = try await APIService(with: defaults).saveSportsGround(id: groundID, form: groundForm).id != .zero
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

private extension SportsGroundFormViewModel {
    func addNewImagesToForm() {
        groundForm.newImagesData = newImages.enumerated().map {
            .init(withImage: $0.element, forKey: ($0.offset + 1).description)
        }
    }
}
