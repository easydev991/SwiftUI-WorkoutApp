import Foundation
import CoreLocation.CLLocation
import UIKit.UIImage

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

    init(with ground: SportsGround?) {
        groundForm = .init(ground)
        groundID = ground?.id
    }

    init(
        _ address: String,
        _ coordinate: CLLocationCoordinate2D,
        _ cityID: Int
    ) {
        groundForm = .init(
            address: address,
            coordinate: coordinate,
            cityID: cityID
        )
    }

    @MainActor
    func saveGround() async {
        if isLoading { return }
        isLoading.toggle()
        do {
            isSuccess = try await APIService().saveSportsGround(id: groundID, form: groundForm).id != .zero
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
