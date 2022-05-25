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
    func makeGrounds(refresh: Bool) async {
        if (isLoading || !list.isEmpty) && !refresh { return }
        isLoading.toggle()
        do {
            list = try await APIService().getAllSportsGrounds()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    @MainActor
    func askForNewGround() async {
        if isLoading { return }
        isLoading.toggle()
        do {
            let dateString = FormatterService.isoStringFromFullDate(Constants.fiveMinutesAgo)
            let newGrounds = try await APIService().getUpdatedSportsGrounds(from: dateString)
            list.append(contentsOf: newGrounds)
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
