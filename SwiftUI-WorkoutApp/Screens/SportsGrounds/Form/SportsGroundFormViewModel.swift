import Foundation
import SWModels
import SWNetworkClient
import UIKit.UIImage

#warning("Лишняя вьюмодель")
@MainActor
final class SportsGroundFormViewModel: ObservableObject {
    @Published var groundForm: SportsGroundForm
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var isSuccess = false
    @Published var newImages = [UIImage]()
    private var groundID: Int?
    private let oldGroundForm: SportsGroundForm

    /// Инициализирует viewModel для изменения существующей площадки
    /// - Parameter ground: вся информация о площадке
    init(with ground: SportsGround) {
        self.groundForm = .init(ground)
        self.groundID = ground.id
        self.oldGroundForm = .init(ground)
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
        self.groundForm = .init(
            address: address,
            latitude: latitude,
            longitude: longitude,
            cityID: cityID
        )
        self.oldGroundForm = .init(
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
            isSuccess = try await SWClient(with: defaults).saveSportsGround(id: groundID, form: groundForm).id != .zero
        } catch {
            errorMessage = ErrorFilter.message(from: error)
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

extension SportsGroundFormViewModel {
    var isFormReady: Bool {
        groundID == nil
            ? groundForm.isReadyToCreate && !newImages.isEmpty
            : groundForm.isReadyToUpdate(old: oldGroundForm) || !newImages.isEmpty
    }

    /// Сколько еще фотографий можно добавить
    var imagesLimit: Int {
        groundID == nil
            ? Constants.photosLimit - newImages.count
            : Constants.photosLimit - newImages.count - groundForm.photosCount
    }

    var isNewSportsGround: Bool {
        groundID == nil
    }
}
