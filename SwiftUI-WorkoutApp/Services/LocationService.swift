//
//  LocationService.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 28.04.2022.
//

import MapKit.MKGeometry

final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var region = MKCoordinateRegion()
    var annotations = Bundle.main.decodeJson(
        [SportsGround].self,
        fileName: "areas.json"
    )

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func setEnabled(_ enabled: Bool) {
        if enabled {
            manager.startUpdatingLocation()
        } else {
            manager.stopUpdatingLocation()
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.last {
            region = .init(
                center: location.coordinate,
                span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .restricted:
            print("--- Запрещен доступ к геолокации")
        case .denied:
            print("--- Отклонен запрос на доступ к геолокации")
        @unknown default: break
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("--- LocationManager столкнулся с ошибкой: \(error.localizedDescription)")
    }
}
