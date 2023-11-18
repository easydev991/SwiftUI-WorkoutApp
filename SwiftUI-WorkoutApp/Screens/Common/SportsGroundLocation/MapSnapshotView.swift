import MapKit
import SWDesignSystem
import SwiftUI
import SWModels

/// Снапшот карты
struct MapSnapshotView: View {
    let ground: SportsGround
    @State private var snapshotImage: UIImage? = nil

    var body: some View {
        GeometryReader { geometry in
            contentView
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
    var contentView: some View {
        ZStack {
            if let image = snapshotImage {
                Image(uiImage: image)
            }
            Image.defaultWorkout
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .background(.black)
                .cornerRadius(12)
                .opacity(snapshotImage == nil ? 1 : 0)
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
                #if DEBUG
                print("--- Error with snapshot: ", error?.localizedDescription ?? "")
                #endif
            }
        }
    }
}

#if DEBUG
#Preview {
    MapSnapshotView(ground: .emptyValue)
}
#endif
