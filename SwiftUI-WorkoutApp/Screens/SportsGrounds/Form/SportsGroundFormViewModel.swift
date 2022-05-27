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
    func saveGround(with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            let result = try await APIService(with: defaults).saveSportsGround(id: groundID, form: groundForm)
            if result.id != .zero {
                isSuccess.toggle()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

private extension SportsGroundFormViewModel {
    func addNewImagesToForm() {
        groundForm.newImagesData = newImages.map {
            $0.jpegData(compressionQuality: .zero) ?? .init()
        }
    }
}
