import MapKit
import SwiftUI

struct MapViewUI: UIViewRepresentable {
    let viewKey: String
    @Binding var region: MKCoordinateRegion
    @Binding var annotations: [SportsGround]
    @Binding var selectedPlace: SportsGround
    @Binding var openDetails: Bool

    private static var mapViewStore = [String : MKMapView]()

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
        mapView.isRotateEnabled = true
        mapView.cameraZoomRange = .init(maxCenterCoordinateDistance: 500000)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
    }

    func makeCoordinator() -> MapCoordinator {
        MapCoordinator(self)
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
            parent.selectedPlace = place
            parent.openDetails.toggle()
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
