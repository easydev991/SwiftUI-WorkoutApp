//
//  SportsGroundsMapViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import Foundation
import Combine
import MapKit.MKGeometry

final class SportsGroundsMapViewModel: ObservableObject {
    @Published var openDetails = false
    @Published var selectedPlace = SportsGround.mock

    private let locationService: LocationService

    var mapRegion: MKCoordinateRegion {
        get { locationService.region }
        set { locationService.region = newValue }
    }

    var mapAnnotations: [SportsGround] {
        get { locationService.annotations }
        set { locationService.annotations = newValue }
    }

    init() {
        locationService = LocationService()
        locationService.setEnabled(true)
    }

    func onDisappearAction() {
        locationService.setEnabled(false)
    }
}
