import MapKit.MKGeometry

final class SportsGroundsMapViewModel: ObservableObject {
    @Published var list = Bundle.main.decodeJson(
        [SportsGround].self,
        fileName: "areas.json"
    )
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published var openDetails = false
    @Published var selectedGround = SportsGround.emptyValue

    private let locationService = LocationService()

    var mapRegion: MKCoordinateRegion {
        get { locationService.region }
        set { locationService.region = newValue }
    }

    @MainActor
    func makeGrounds(with defaults: DefaultsService, refresh: Bool) async {
        if (isLoading || !list.isEmpty) && !refresh { return }
        isLoading.toggle()
        do {
            list = try await APIService(with: defaults).getAllSportsGrounds()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func onAppearAction() {
        locationService.setEnabled(true)
    }

    func onDisappearAction() {
        locationService.setEnabled(false)
    }

    func clearErrorMessage() { errorMessage = "" }
}
