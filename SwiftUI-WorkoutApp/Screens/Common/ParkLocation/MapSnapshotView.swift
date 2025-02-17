import MapKit
import OSLog
import SWDesignSystem
import SwiftUI

/// Снапшот карты
struct MapSnapshotView: View {
    let mapModel: MapModel
    let size: CGSize
    @State private var snapshotImage: UIImage?

    var body: some View {
        contentView
            .animation(.easeInOut, value: snapshotImage)
            .onAppear(perform: generateSnapshot)
            .onChange(of: mapModel) { _ in
                generateSnapshot()
            }
    }
}

extension MapSnapshotView {
    struct MapModel: Equatable {
        let latitude: Double
        let longitude: Double

        var coordinate: CLLocationCoordinate2D {
            .init(latitude: latitude, longitude: longitude)
        }

        var isComplete: Bool {
            latitude != 0 && longitude != 0
        }
    }
}

private extension MapSnapshotView {
    var contentView: some View {
        ZStack {
            if let image = snapshotImage {
                Image(uiImage: image)
                    .transition(.scale)
            } else {
                Image.defaultWorkout
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width, height: size.height)
                    .background(.black)
                    .cornerRadius(12)
                    .transition(.opacity.combined(with: .scale))
            }
        }
    }

    @MainActor
    func generateSnapshot() {
        guard mapModel.isComplete else { return }
        let regionRadius: CLLocationDistance = 1000
        let options = MKMapSnapshotter.Options()
        options.region = .init(
            center: mapModel.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
        options.size = .init(width: size.width, height: size.height)
        options.pointOfInterestFilter = .excludingAll

        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            if let snapshot {
                let image = UIGraphicsImageRenderer(size: options.size).image { _ in
                    snapshot.image.draw(at: .zero)
                    let point = snapshot.point(for: mapModel.coordinate)
                    let annotationView = MKMarkerAnnotationView(
                        annotation: nil,
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
                let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MapSnapshotView")
                logger.error("Ошибка при создании снапшота карты: \(error, privacy: .public)")
            }
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        MapSnapshotView(
            mapModel: .init(
                latitude: 55.687001,
                longitude: 37.504467
            ),
            size: .init(width: 350, height: 150)
        )
    }
}
#endif
