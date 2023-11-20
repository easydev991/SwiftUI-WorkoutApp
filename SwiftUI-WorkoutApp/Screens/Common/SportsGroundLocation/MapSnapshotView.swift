import MapKit
import SWDesignSystem
import SwiftUI
import SWModels

/// Снапшот карты
struct MapSnapshotView: View {
    let model: Model
    @State private var snapshotImage: UIImage? = nil

    var body: some View {
        GeometryReader { geometry in
            contentView(size: geometry.size)
                .animation(.easeInOut, value: snapshotImage)
                .onAppear {
                    generateSnapshot(for: geometry.size)
                }
                .onChange(of: model) { _ in
                    generateSnapshot(for: geometry.size)
                }
        }
    }
}

extension MapSnapshotView {
    struct Model: Equatable {
        let latitude: Double
        let longitude: Double
        
        var coordinate: CLLocationCoordinate2D {
            .init(latitude: latitude, longitude: longitude)
        }
    }
}

private extension MapSnapshotView {
    func contentView(size: CGSize) -> some View {
        ZStack {
            if let image = snapshotImage {
                Image(uiImage: image)
            } else {
                Image.defaultWorkout
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .background(.black)
                    .cornerRadius(12)
            }
        }
    }

    @MainActor
    func generateSnapshot(for size: CGSize) {
        if snapshotImage != nil
            || model.coordinate.latitude == .zero
            || model.coordinate.longitude == .zero {
            return
        }
        snapshotImage = nil
        let spanDelta: CLLocationDegrees = 0.002
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(
            center: model.coordinate,
            span: .init(
                latitudeDelta: spanDelta,
                longitudeDelta: spanDelta
            )
        )
        options.size = .init(width: size.width, height: size.height)
        options.pointOfInterestFilter = .excludingAll

        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            if let snapshot {
                let image = UIGraphicsImageRenderer(size: options.size).image { _ in
                    snapshot.image.draw(at: .zero)
                    let point = snapshot.point(for: model.coordinate)
                    let annotationView = MKMarkerAnnotationView(
                        annotation: SnapshotAnnotation(coordinate: model.coordinate),
                        reuseIdentifier: nil
                    )
                    annotationView.contentMode = .scaleAspectFit
                    annotationView.bounds = .init(x: 0, y: 0, width: 40, height: 40)
                    let viewBounds = annotationView.bounds
                    annotationView.drawHierarchy(
                        in: .init(
                            x: point.x - viewBounds.width / 2,
                            y: point.y - viewBounds.height,
                            width: viewBounds.width,
                            height: viewBounds.height
                        ),
                        afterScreenUpdates: true
                    )
                }
                snapshotImage = image
            } else {
                snapshotImage = nil
                #if DEBUG
                print("--- Ошибка при создании снапшота карты: ", error?.localizedDescription ?? "")
                #endif
            }
        }
    }
}

private final class SnapshotAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

#if DEBUG
#Preview {
    MapSnapshotView(model: .init(latitude: 0, longitude: 0))
}
#endif
