//
//  MapSnapshotView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 24.04.2022.
//

import SwiftUI
import MapKit

struct MapSnapshotView: View {
    let model: SportsGround
    @State private var snapshotImage: UIImage? = nil

    var body: some View {
        GeometryReader { geometry in
            content
                .onAppear {
                    generateSnapshot(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                }
        }
    }
}

private extension MapSnapshotView {
    var content: AnyView {
        if let image = snapshotImage {
            return AnyView(Image(uiImage: image))
        } else {
            return AnyView(centeredProgressView)
        }
    }

    var centeredProgressView: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            Spacer()
        }
    }

    func generateSnapshot(width: CGFloat, height: CGFloat) {
        let spanDelta: CLLocationDegrees = 0.002
        let region = MKCoordinateRegion(
            center: model.coordinate,
            span: .init(
                latitudeDelta: spanDelta,
                longitudeDelta: spanDelta
            )
        )
        let options = MKMapSnapshotter.Options()
        options.region = region
        options.size = .init(width: width, height: height)
        options.pointOfInterestFilter = .excludingAll

        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            if let snapshot = snapshot {
                let image = UIGraphicsImageRenderer(size: options.size).image { _ in
                    snapshot.image.draw(at: .zero)
                    let point = snapshot.point(for: model.coordinate)
                    let annotationView = MKMarkerAnnotationView(annotation: model, reuseIdentifier: nil)
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
                print("Error with snapshot: ",error?.localizedDescription ?? "")
            }
        }
    }
}

struct MapSnapshotView_Previews: PreviewProvider {
    static var previews: some View {
        MapSnapshotView(model: SportsGround.mock)
            .frame(width: .infinity, height: 150)
    }
}
