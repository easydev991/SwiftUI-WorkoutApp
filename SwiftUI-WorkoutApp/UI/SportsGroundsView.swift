//
//  SportsGroundsView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI
import MapKit

struct SportsGroundsView: View {
    @State private var locationManager = LocationManager()

    var body: some View {
        NavigationView {
            Map(
                coordinateRegion: $locationManager.region,
                interactionModes: .pan,
                showsUserLocation: true,
                annotationItems: locationManager.mappedPoints,
                annotationContent: { item in
                    MapMarker(coordinate: item.coordinate, tint: .red)
                }
            )
            .navigationTitle("Площадки")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SportsGroundsView_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundsView()
    }
}

final class LocationManager: NSObject, ObservableObject {
    @Published var region = MKCoordinateRegion()
    private let locationManager = CLLocationManager()
    private var isLocationFound = false
    let mappedPoints = Bundle.main.decodeJson(
        [SportsGround].self,
        fileName: "areas.json"
    ).map { area -> AnnotatedArea in
        return .init(
            name: area.name,
            coordinate: .init(
                latitude: .init(Double(area.latitude) ?? .zero),
                longitude: .init(Double(area.longitude) ?? .zero)
            )
        )
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

extension LocationManager {
    struct AnnotatedArea: Identifiable {
        let id = UUID()
        let name: String
        let coordinate: CLLocationCoordinate2D
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.last, !isLocationFound {
            isLocationFound.toggle()
            region = .init(
                center: location.coordinate,
                span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        } else {
            locationManager.stopUpdatingLocation()
        }
    }
}
