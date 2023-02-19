import MapKit
import SwiftUI
import SWModels

/// Снапшот карты
struct MapSnapshotView: View {
    @Binding var ground: SportsGround
    @State private var snapshotImage: UIImage? = nil

    var body: some View {
        GeometryReader { geometry in
            contentView(placeholderSize: geometry.size)
                .animation(.easeInOut, value: snapshotImage)
                .onAppear {
                    generateSnapshot(for: geometry.size)
                }
                .onChange(of: ground) { _ in
                    generateSnapshot(for: geometry.size)
                }
        }
    }
}

private extension MapSnapshotView {
    @ViewBuilder
    func contentView(placeholderSize: CGSize) -> some View {
        if let image = snapshotImage {
            Image(uiImage: image)
        } else {
            RoundedDefaultImage(size: placeholderSize)
        }
    }

    func generateSnapshot(for size: CGSize) {
        if snapshotImage != nil
            || ground.coordinate.latitude == .zero
            || ground.coordinate.longitude == .zero {
            return
        }
        snapshotImage = nil
        let spanDelta: CLLocationDegrees = 0.002
        let region = MKCoordinateRegion(
            center: ground.coordinate,
            span: .init(
                latitudeDelta: spanDelta,
                longitudeDelta: spanDelta
            )
        )
        let options = MKMapSnapshotter.Options()
        options.region = region
        options.size = .init(width: size.width, height: size.height)
        options.pointOfInterestFilter = .excludingAll

        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            if let snapshot {
                let image = UIGraphicsImageRenderer(size: options.size).image { _ in
                    snapshot.image.draw(at: .zero)
                    let point = snapshot.point(for: ground.coordinate)
                    let annotationView = MKMarkerAnnotationView(
                        annotation: ground, reuseIdentifier: nil
                    )
                    annotationView.contentMode = .scaleAspectFit
                    annotationView.bounds = .init(x: .zero, y: .zero, width: 40, height: 40)
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
                #if DEBUG
                print("--- Error with snapshot: ", (error?.localizedDescription).valueOrEmpty)
                #endif
            }
        }
    }
}

#if DEBUG
struct MapSnapshotView_Previews: PreviewProvider {
    static var previews: some View {
        MapSnapshotView(ground: .constant(.emptyValue))
            .frame(width: .infinity, height: 150)
            .previewLayout(.sizeThatFits)
    }
}
#endif
