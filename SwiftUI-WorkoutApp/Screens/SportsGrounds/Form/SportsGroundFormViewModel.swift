import Foundation
import CoreLocation.CLLocation

final class SportsGroundFormViewModel: ObservableObject {
    @Published var groundForm: SportsGroundForm
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var isSuccess = false
    private var groundID: Int?

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
