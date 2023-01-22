import Foundation
import UIKit.UIImage

@MainActor
final class SportsGroundFormViewModel: ObservableObject {
    @Published var groundForm: SportsGroundForm
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var isSuccess = false
    @Published var newImages = [UIImage]()
    private var groundID: Int?
    private let oldGroundForm: SportsGroundForm
    var isFormReady: Bool {
        groundID == nil
        ? groundForm.isReadyToCreate && !newImages.isEmpty
        : groundForm.isReadyToUpdate(old: oldGroundForm) || !newImages.isEmpty
    }
    var imagesLimit: Int {
        groundID == nil
        ? Constants.photosLimit - newImages.count
        : Constants.photosLimit - newImages.count - groundForm.photosCount
    }
    var canAddImages: Bool {
        guard !isLoading else { return false }
        return groundID == nil
        ? newImages.count < Constants.photosLimit
        : (newImages.count + groundForm.photosCount) < Constants.photosLimit
    }
    var isNewSportsGround: Bool {
        groundID == nil
    }

    /// Инициализирует viewModel для изменения существующей площадки
    /// - Parameter ground: вся информация о площадке
    init(with ground: SportsGround) {
        groundForm = .init(ground)
        groundID = ground.id
        oldGroundForm = .init(ground)
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
        oldGroundForm = .init(
            address: address,
            latitude: latitude,
            longitude: longitude,
            cityID: cityID
        )
    }

    func deleteExtraImagesIfNeeded() {
        while imagesLimit < 0 {
            newImages.removeLast()
        }
    }

    func saveGround(with defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        groundForm.newMediaFiles = newImages.toMediaFiles
        do {
            isSuccess = try await APIService(with: defaults).saveSportsGround(id: groundID, form: groundForm).id != .zero
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}
