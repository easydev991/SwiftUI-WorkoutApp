import MapKit.MKGeometry

final class SportsGroundsMapViewModel: ObservableObject {
    @Published var openDetails = false
    @Published var selectedPlace = SportsGround.emptyValue

    private let locationService: LocationService

    var mapRegion: MKCoordinateRegion {
        get { locationService.region }
        set { locationService.region = newValue }
    }

    init() {
        locationService = LocationService()
    }

    func onAppearAction() {
        locationService.setEnabled(true)
    }

    func onDisappearAction() {
        locationService.setEnabled(false)
    }
}
