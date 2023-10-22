import MapKit
import SwiftUI

struct MKMapViewRepresentable: UIViewRepresentable {
    private static var storedMapView: MKMapView?
    private let region: MKCoordinateRegion
    private let cameraZoomRange: MKMapView.CameraZoomRange?
    private let hideTrackingButton: Bool
    private let showsUserLocation: Bool
    private let annotations: [any MKAnnotation]
    private let markerColors: MarkerColors
    private let openSelected: (any MKAnnotation) -> Void
    
    /// Инициализатор
    /// - Parameters:
    ///   - region: Регион для отображения
    ///   - cameraZoomRange: Диапазон зума карты (мин/макс), по умолчанию 500/5000000
    ///   - showTrackingButton: Нужно ли показывать справа сверху кнопку трекинга локации
    ///   - showsUserLocation: Нужно ли показывать текущую локацию пользователя, по умолчанию `true`
    ///   - annotations: Массив аннотаций (точек) для отображения на карте
    ///   - markerColors: Цвета для маркеров аннотаций, по умолчанию `orange` для кластера и `red` для обычной аннотации
    ///   - openSelected: Возвращает аннотацию, чью карточку с информацией нажал пользователь
    init(
        region: MKCoordinateRegion,
        cameraZoomRange: MKMapView.CameraZoomRange? = .init(
            minCenterCoordinateDistance: 500,
            maxCenterCoordinateDistance: 5000000
        ),
        hideTrackingButton: Bool,
        showsUserLocation: Bool = true,
        annotations: [any MKAnnotation],
        markerColors: MarkerColors = .init(),
        openSelected: @escaping (any MKAnnotation) -> Void
    ) {
        self.region = region
        self.cameraZoomRange = cameraZoomRange
        self.hideTrackingButton = hideTrackingButton
        self.showsUserLocation = showsUserLocation
        self.annotations = annotations
        self.markerColors = markerColors
        self.openSelected = openSelected
    }

    func makeUIView(context: Context) -> MKMapView {
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

    func updateUIView(_ mapView: MKMapView, context: Context) {
        setTrackingButton(hideTrackingButton, on: mapView)
        context.coordinator.updateIfNeeded(mapView, with: annotations, in: region)
    }

    func makeCoordinator() -> Coordinator { .init(self) }
}

extension MKMapViewRepresentable {
    final class Coordinator: NSObject, MKMapViewDelegate {
        private let annotationID = "SingleAnnotation"
        private let clusterID = "Cluster"
        private let parent: MKMapViewRepresentable

        init(_ parent: MKMapViewRepresentable) { self.parent = parent }

        func mapView(_: MKMapView, didSelect view: MKAnnotationView) {
            switch view.annotation {
            case is MKClusterAnnotation, is MKUserLocation: break
            default:
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
            with annotations: [any MKAnnotation],
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
            let filteredMapAnnotations = mapAnnotations.filter {
                type(of: $0) != MKClusterAnnotation.self && type(of: $0) != MKUserLocation.self
            }
            if annotations.count != filteredMapAnnotations.count {
                if !mapAnnotations.isEmpty {
                    mapView.removeAnnotations(mapAnnotations)
                }
                mapView.addAnnotations(annotations)
            }
        }

        func mapView(_: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped _: UIControl) {
            if let annotation = view.annotation { parent.openSelected(annotation) }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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

extension MKMapViewRepresentable {
    struct MarkerColors {
        /// Цвет маркера для кластера
        let cluster: UIColor
        /// Цвет маркера для обычной аннотации
        let regular: UIColor
        
        init(cluster: UIColor = .orange, regular: UIColor = .red) {
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
