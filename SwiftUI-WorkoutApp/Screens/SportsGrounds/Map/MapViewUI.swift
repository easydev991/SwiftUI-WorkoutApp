import MapKit
import SwiftUI

struct MapViewUI: UIViewRepresentable {
    /// Уникальный идентификатор карты, чтобы не плодить дубли
    let viewKey: String
    let region: MKCoordinateRegion
    let annotations: [SportsGround]
    @Binding var needUpdateAnnotations: Bool
    @Binding var needUpdateRegion: Bool
    @Binding var ignoreUserLocation: Bool
    let openSelected: (SportsGround) -> Void
    private static var mapViewStore = [String: MKMapView]()

    init(
        _ key: String,
        _ region: MKCoordinateRegion,
        _ pins: [SportsGround],
        _ needUpdatePins: Binding<Bool>,
        _ needUpdateRegion: Binding<Bool>,
        _ ignoreUserLocation: Binding<Bool>,
        openDetailsClbk: @escaping (SportsGround) -> Void
    ) {
        self.viewKey = key
        self.region = region
        self.annotations = pins
        self._needUpdateAnnotations = needUpdatePins
        self._needUpdateRegion = needUpdateRegion
        self._ignoreUserLocation = ignoreUserLocation
        self.openSelected = openDetailsClbk
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView: MKMapView
        if let storedView = MapViewUI.mapViewStore[viewKey] {
            storedView.delegate = context.coordinator
            mapView = storedView
        } else {
            let newView = MKMapView(frame: .zero)
            newView.delegate = context.coordinator
            MapViewUI.mapViewStore[viewKey] = newView
            mapView = newView
        }
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        mapView.cameraZoomRange = .init(maxCenterCoordinateDistance: 500000)
        addTrackingButton(to: mapView)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        if needUpdateAnnotations {
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(annotations)
            needUpdateAnnotations.toggle()
        }
        if needUpdateRegion {
            mapView.setRegion(region, animated: false)
            needUpdateRegion.toggle()
        }
        if ignoreUserLocation {
            setTrackingButtonHidden(true, on: mapView)
        } else {
            setTrackingButtonHidden(false, on: mapView)
        }
    }

    func makeCoordinator() -> MapCoordinator { .init(self) }
}

private extension MapViewUI {
    func addTrackingButton(to mapView: MKMapView) {
        if mapView.subviews.contains(where: { $0 is MKUserTrackingButton }) {
            return
        }
        let trackingButton = MKUserTrackingButton(mapView: mapView)
        trackingButton.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(trackingButton)
        NSLayoutConstraint.activate([
            trackingButton.topAnchor.constraint(
                equalTo: mapView.layoutMarginsGuide.topAnchor,
                constant: 60
            ),
            trackingButton.trailingAnchor.constraint(
                equalTo: mapView.layoutMarginsGuide.trailingAnchor,
                constant: -8
            )
        ])
    }

    func setTrackingButtonHidden(_ isHidden: Bool, on mapView: MKMapView) {
        guard let trackingButton = mapView.subviews.first(where: { $0 is MKUserTrackingButton }) else { return
        }
        if isHidden && trackingButton.isHidden
            || !isHidden && !trackingButton.isHidden {
            return
        }
        trackingButton.isHidden = isHidden
    }
}

final class MapCoordinator: NSObject, MKMapViewDelegate {
    private let annotationIdentifier = "SportsGround"
    private let clusterIdentifier = "Cluster"
    private let parent: MapViewUI

    init(_ parent: MapViewUI) {
        self.parent = parent
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is SportsGround {
            let button = UIButton(type: .detailDisclosure)
            view.rightCalloutAccessoryView = button
        }
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let place = view.annotation as? SportsGround {
            parent.openSelected(place)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is MKClusterAnnotation:
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: clusterIdentifier) as? MKMarkerAnnotationView
            ?? .init(annotation: annotation, reuseIdentifier: clusterIdentifier)
            view.canShowCallout = true
            view.markerTintColor = .orange
            view.titleVisibility = .visible
            return view
        case is SportsGround:
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKMarkerAnnotationView
            ?? .init(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.canShowCallout = true
            view.glyphImage = .init(systemName: "mappin")
            view.clusteringIdentifier = clusterIdentifier
            view.markerTintColor = .red
            view.titleVisibility = .visible
            view.subtitleVisibility = .adaptive
            return view
        default:
            return nil
        }
    }
}
