import MapKit
import SwiftUI

/// `MKMapView` в обертке для `SwiftUI` с базовыми настройками
public struct ClusteringMapView: UIViewRepresentable {
    private static var storedMapView: MKMapView?
    private let region: MKCoordinateRegion
    private let shouldUpdateRegion: Bool
    private let onRegionUpdated: () -> Void
    private let cameraZoomRange: MKMapView.CameraZoomRange?
    private let hideTrackingButton: Bool
    private let annotations: [any MKAnnotation]
    private let markerColors: MarkerColors
    private let didSelect: (any MKAnnotation) -> Void

    /// Инициализатор
    /// - Parameters:
    ///   - region: Регион для отображения
    ///   - shouldUpdateRegion: Нужно ли обновить регион. Используется во избежание лишних обновлений в методе `updateUIView`
    ///   - onRegionUpdated: Сообщает о факте изменения региона карты из метода `updateUIView`
    ///   - cameraZoomRange: Диапазон зума карты (мин/макс), по умолчанию 500/5000000
    ///   - showTrackingButton: Нужно ли показывать справа сверху кнопку трекинга локации
    ///   - annotations: Массив аннотаций (точек) для отображения на карте
    ///   - markerColors: Цвета для маркеров аннотаций, по умолчанию `orange` для кластера и `red` для обычной аннотации
    ///   - didSelect: Возвращает аннотацию, чью карточку с информацией нажал пользователь
    public init(
        region: MKCoordinateRegion,
        shouldUpdateRegion: Bool,
        onRegionUpdated: @escaping () -> Void,
        cameraZoomRange: MKMapView.CameraZoomRange? = .init(
            minCenterCoordinateDistance: 500,
            maxCenterCoordinateDistance: 5000000
        ),
        hideTrackingButton: Bool,
        annotations: [any MKAnnotation],
        markerColors: MarkerColors = .init(),
        didSelect: @escaping (any MKAnnotation) -> Void
    ) {
        self.region = region
        self.shouldUpdateRegion = shouldUpdateRegion
        self.onRegionUpdated = onRegionUpdated
        self.cameraZoomRange = cameraZoomRange
        self.hideTrackingButton = hideTrackingButton
        self.annotations = annotations
        self.markerColors = markerColors
        self.didSelect = didSelect
    }

    public func makeUIView(context: Context) -> MKMapView {
        let view = if let storedView = ClusteringMapView.storedMapView {
            storedView
        } else {
            MKMapView()
        }
        view.delegate = context.coordinator
        view.cameraZoomRange = cameraZoomRange
        addTrackingButtonIfNeeded(to: view)
        if ClusteringMapView.storedMapView == nil {
            // Если не сохранить карту, могут создаваться дубли
            ClusteringMapView.storedMapView = view
        }
        return view
    }

    public func updateUIView(_ mapView: MKMapView, context _: Context) {
        setTrackingButton(hideTrackingButton, on: mapView)
        if shouldUpdateRegion {
            RegionOrganizer(old: mapView.region, new: region).updateIfNeeded(for: mapView)
            DispatchQueue.main.async {
                onRegionUpdated()
            }
        }
        AnnotationsOrganizer(old: mapView.annotations, new: annotations).updateIfNeeded(for: mapView)
    }

    public func makeCoordinator() -> Coordinator { .init(self) }
}

public extension ClusteringMapView {
    final class Coordinator: NSObject, MKMapViewDelegate {
        private let annotationId = "RegularAnnotation"
        private let clusterId = "Cluster"
        private let parent: ClusteringMapView

        init(_ parent: ClusteringMapView) { self.parent = parent }

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
                view = mapView.dequeueReusableAnnotationView(withIdentifier: clusterId) as? MKMarkerAnnotationView
                    ?? .init(annotation: annotation, reuseIdentifier: clusterId)
                view.markerTintColor = parent.markerColors.cluster
            default:
                view = mapView.dequeueReusableAnnotationView(withIdentifier: annotationId) as? MKMarkerAnnotationView
                    ?? .init(annotation: annotation, reuseIdentifier: annotationId)
                view.canShowCallout = true
                view.clusteringIdentifier = clusterId
                view.markerTintColor = parent.markerColors.regular
                view.titleVisibility = .visible
                view.subtitleVisibility = .adaptive
            }
            return view
        }
    }
}

private extension ClusteringMapView {
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
