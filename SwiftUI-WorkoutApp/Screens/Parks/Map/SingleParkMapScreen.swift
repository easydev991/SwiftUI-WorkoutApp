import ClusteringMapView
import MapKit
import SwiftUI

/// Экран с картой для единственной площадки
struct SingleParkMapScreen: View {
    private let model: Model
    /// Регион для `iOS < 17`
    @State private var region: MKCoordinateRegion

    init(lat: Double, lon: Double) {
        let coordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        self.model = .init(coordinate2D: coordinate2D)
        self._region = .init(
            initialValue: .init(
                center: coordinate2D,
                span: .init(
                    latitudeDelta: 0.05,
                    longitudeDelta: 0.05
                )
            )
        )
    }

    var body: some View {
        if #available(iOS 17.0, *) {
            Map(
                bounds: .init(
                    minimumDistance: 500,
                    maximumDistance: 20000
                )
            ) {
                Marker("Площадка", coordinate: model.coordinate2D)
                UserAnnotation()
            }
            .mapControlVisibility(.visible)
        } else {
            Map(
                coordinateRegion: $region,
                showsUserLocation: true,
                annotationItems: [model],
                annotationContent: { park in
                    MapMarker(coordinate: park.coordinate2D, tint: .red)
                }
            )
            .ignoresSafeArea()
        }
    }
}

private extension SingleParkMapScreen {
    struct Model: Identifiable {
        /// Идентификатор для `iOS < 17`
        let id = UUID().uuidString
        let coordinate2D: CLLocationCoordinate2D
    }
}

#if DEBUG
#Preview {
    SingleParkMapScreen(
        lat: 55.795396,
        lon: 37.762597
    )
}
#endif
