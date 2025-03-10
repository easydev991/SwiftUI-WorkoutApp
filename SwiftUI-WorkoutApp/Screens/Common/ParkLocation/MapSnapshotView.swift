@preconcurrency import MapKit
import OSLog
import SWDesignSystem
import SwiftUI

/// Снимок карты
struct MapSnapshotView: View {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "MapSnapshotView"
    )
    private let height: CGFloat = 153
    @State private var snapshotImage: UIImage?
    @State private var currentSize: CGSize?
    let mapModel: MapModel

    var body: some View {
        GeometryReader { geo in
            makeContentView(width: geo.size.width)
                .animation(.easeInOut, value: snapshotImage)
                .clipShape(.rect(cornerRadius: 8))
                .task(id: mapModel) {
                    await generateSnapshot(size: geo.size)
                }
                .task(id: geo.size) {
                    await generateSnapshot(size: geo.size)
                }
        }
        .frame(height: height)
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
    func makeContentView(width: CGFloat) -> some View {
        ZStack {
            if let snapshotImage {
                Image(uiImage: snapshotImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
                    .transition(.opacity.combined(with: .scale))
            } else {
                Image.defaultWorkout
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
                    .background(.black)
                    .clipShape(.rect(cornerRadius: 12))
                    .transition(.opacity.combined(with: .scale))
            }
        }
    }

    @MainActor
    func generateSnapshot(size: CGSize) async {
        guard mapModel.isComplete else {
            logger.error("Широта или долгота отсутствует!")
            return
        }
        guard currentSize != size else {
            logger.info("Пропускаем лишнюю генерацию картинки, т.к. размеры не изменились")
            return
        }
        currentSize = size
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
        do {
            let snapshot = try await snapshotter.start()
            let image = await withCheckedContinuation { continuation in
                let result = UIGraphicsImageRenderer(size: options.size).image { _ in
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
                continuation.resume(returning: result)
            }
            snapshotImage = image
        } catch {
            logger.error("Ошибка при создании снапшота карты: \(error, privacy: .public)")
            snapshotImage = nil
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
            )
        )
    }
}
#endif
