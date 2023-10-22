import MapKit
import SwiftUI

/// `MKMapView` в обертке для `SwiftUI` с базовыми настройками
public struct MKMapViewRepresentable: UIViewRepresentable {
    private static var storedMapView: MKMapView?
    private let region: MKCoordinateRegion
    private let cameraZoomRange: MKMapView.CameraZoomRange?
    private let hideTrackingButton: Bool
    private let showsUserLocation: Bool
    private let annotations: [any MKAnnotation]
    private let markerColors: MarkerColors
    private let didSelect: (any MKAnnotation) -> Void

    /// Инициализатор
    /// - Parameters:
    ///   - region: Регион для отображения
    ///   - cameraZoomRange: Диапазон зума карты (мин/макс), по умолчанию 500/5000000
    ///   - showTrackingButton: Нужно ли показывать справа сверху кнопку трекинга локации
    ///   - showsUserLocation: Нужно ли показывать текущую локацию пользователя, по умолчанию `true`
    ///   - annotations: Массив аннотаций (точек) для отображения на карте
    ///   - markerColors: Цвета для маркеров аннотаций, по умолчанию `orange` для кластера и `red` для обычной аннотации
    ///   - didSelect: Возвращает аннотацию, чью карточку с информацией нажал пользователь
    public init(
        region: MKCoordinateRegion,
        cameraZoomRange: MKMapView.CameraZoomRange? = .init(
            minCenterCoordinateDistance: 500,
            maxCenterCoordinateDistance: 5000000
        ),
        hideTrackingButton: Bool,
        showsUserLocation: Bool = true,
        annotations: [any MKAnnotation],
        markerColors: MarkerColors = .init(),
        didSelect: @escaping (any MKAnnotation) -> Void
    ) {
        self.region = region
        self.cameraZoomRange = cameraZoomRange
        self.hideTrackingButton = hideTrackingButton
        self.showsUserLocation = showsUserLocation
        self.annotations = annotations
        self.markerColors = markerColors
        self.didSelect = didSelect
    }

    public func makeUIView(context: Context) -> MKMapView {
        let view = if let storedView = MKMapViewRepresentable.storedMapView {
            storedView
        } else {
            MKMapView()
        }
        view.delegate = context.coordinator
        view.showsUserLocation = showsUserLocation
        view.cameraZoomRange = cameraZoomRange
        addTrackingButtonIfNeeded(to: view)
        if MKMapViewRepresentable.storedMapView == nil {
            // Если не сохранить карту, будут создаваться дубли
            MKMapViewRepresentable.storedMapView = view
        }
        return view
    }

    public func updateUIView(_ mapView: MKMapView, context _: Context) {
        setTrackingButton(hideTrackingButton, on: mapView)
        RegionOrganizer(old: mapView.region, new: region)
            .updateRegionIfNeeded(for: mapView)
        AnnotationsOrganizer(old: mapView.annotations, new: annotations)
            .updateAnnotationsIfNeeded(for: mapView)
    }

    public func makeCoordinator() -> Coordinator { .init(self) }
}

public extension MKMapViewRepresentable {
    final class Coordinator: NSObject, MKMapViewDelegate {
        private let annotationID = "RegularAnnotation"
        private let clusterID = "Cluster"
        private let parent: MKMapViewRepresentable

        init(_ parent: MKMapViewRepresentable) { self.parent = parent }

        public func mapView(_: MKMapView, didSelect view: MKAnnotationView) {
            switch view.annotation {
            case is MKClusterAnnotation, is MKUserLocation: break
            default:
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
        }

        public func mapView(_: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped _: UIControl) {
            if let annotation = view.annotation { parent.didSelect(annotation) }
        }

        public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let view: MKMarkerAnnotationView
            switch annotation {
            case is MKUserLocation: return nil
            case is MKClusterAnnotation:
                view = mapView.dequeueReusableAnnotationView(withIdentifier: clusterID) as? MKMarkerAnnotationView
                    ?? .init(annotation: annotation, reuseIdentifier: clusterID)
                view.markerTintColor = parent.markerColors.cluster
            default:
                view = mapView.dequeueReusableAnnotationView(withIdentifier: annotationID) as? MKMarkerAnnotationView
                    ?? .init(annotation: annotation, reuseIdentifier: annotationID)
                view.canShowCallout = true
                view.clusteringIdentifier = clusterID
                view.markerTintColor = parent.markerColors.regular
                view.titleVisibility = .visible
                view.subtitleVisibility = .adaptive
            }
            return view
        }
    }
}

public extension MKMapViewRepresentable {
    struct MarkerColors {
        /// Цвет маркера для кластера
        let cluster: UIColor
        /// Цвет маркера для обычной аннотации
        let regular: UIColor

        public init(cluster: UIColor = .orange, regular: UIColor = .red) {
            self.cluster = cluster
            self.regular = regular
        }
    }
}

private extension MKMapViewRepresentable {
    func addTrackingButtonIfNeeded(to mapView: MKMapView) {
        guard !mapView.subviews.contains(where: { $0 is MKUserTrackingButton }) else { return }
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

    func setTrackingButton(_ hidden: Bool, on mapView: MKMapView) {
        guard let trackingButton = mapView.subviews.first(where: { $0 is MKUserTrackingButton }) else { return }
        switch (hidden, trackingButton.isHidden) {
        case (true, true), (false, false): break
        default: trackingButton.isHidden = hidden
        }
    }
}
