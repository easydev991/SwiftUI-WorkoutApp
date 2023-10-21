import MapKit
import SwiftUI
import SWModels

struct MapViewUI: UIViewRepresentable {
    private static var storedMapView: MKMapView?
    let region: MKCoordinateRegion
    let ignoreUserLocation: Bool
    let annotations: [SportsGround]
    let openSelected: (SportsGround) -> Void

    func makeUIView(context: Context) -> MKMapView {
        let view = if let storedView = MapViewUI.storedMapView {
            storedView
        } else {
            MKMapView()
        }
        view.delegate = context.coordinator
        view.showsUserLocation = true
        view.cameraZoomRange = .init(maxCenterCoordinateDistance: 5000000)
        addTrackingButton(to: view)
        if MapViewUI.storedMapView == nil {
            MapViewUI.storedMapView = view
        }
        return view
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        setTrackingButtonHidden(ignoreUserLocation, on: mapView)
        context.coordinator.updateIfNeeded(mapView, with: annotations, in: region)
    }

    func makeCoordinator() -> Coordinator { .init(self) }
}

extension MapViewUI {
    final class Coordinator: NSObject, MKMapViewDelegate {
        private let annotationID = "SportsGround"
        private let clusterID = "Cluster"
        private let parent: MapViewUI

        init(_ parent: MapViewUI) { self.parent = parent }

        func mapView(_: MKMapView, didSelect view: MKAnnotationView) {
            if view.annotation is SportsGround {
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
        }

        /// Обновляет карту, если это необходимо
        /// - Parameters:
        ///   - mapView: Карта, которую нужно обновить
        ///   - annotations: Актуальные точки
        ///   - region: Актуальный регион
        func updateIfNeeded(
            _ mapView: MKMapView,
            with annotations: [SportsGround],
            in region: MKCoordinateRegion
        ) {
            if mapView.region.center.latitude != region.center.latitude,
               mapView.region.center.longitude != region.center.longitude {
                mapView.setRegion(region, animated: true)
            }
            let mapAnnotations = mapView.annotations
            if annotations.isEmpty, mapAnnotations.isEmpty {
                // Нет точек на карте, ничего не делаем
                return
            }
            let filteredMapAnnotations = mapAnnotations.filter { $0 is SportsGround }
            if annotations.count != filteredMapAnnotations.count {
                if !mapAnnotations.isEmpty {
                    mapView.removeAnnotations(mapAnnotations)
                }
                mapView.addAnnotations(annotations)
            }
        }

        func mapView(_: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped _: UIControl) {
            if let ground = view.annotation as? SportsGround { parent.openSelected(ground) }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let view: MKMarkerAnnotationView
            switch annotation {
            case is MKClusterAnnotation:
                view = mapView.dequeueReusableAnnotationView(withIdentifier: clusterID) as? MKMarkerAnnotationView
                    ?? .init(annotation: annotation, reuseIdentifier: clusterID)
                view.markerTintColor = .orange
            case is SportsGround:
                view = mapView.dequeueReusableAnnotationView(withIdentifier: annotationID) as? MKMarkerAnnotationView
                    ?? .init(annotation: annotation, reuseIdentifier: annotationID)
                view.canShowCallout = true
                view.clusteringIdentifier = clusterID
                view.markerTintColor = .red
                view.titleVisibility = .visible
                view.subtitleVisibility = .adaptive
            default: return nil
            }
            return view
        }
    }
}

private extension MapViewUI {
    func addTrackingButton(to mapView: MKMapView) {
        if mapView.subviews.contains(where: { $0 is MKUserTrackingButton }) { return }
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

    func setTrackingButtonHidden(_ newValue: Bool, on mapView: MKMapView) {
        guard let trackingButton = mapView.subviews.first(where: { $0 is MKUserTrackingButton }) else { return }
        switch (newValue, trackingButton.isHidden) {
        case (true, true), (false, false): break
        default: trackingButton.isHidden = newValue
        }
    }
}
