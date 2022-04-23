//
//  SportsGroundsMapView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI
import MapKit

struct SportsGroundsMapView: View {
    @EnvironmentObject var appState: AppState
    @State private var openDetails = false
    @State private var selectedPlace = SportsGround.mock

    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(isActive: $openDetails) {
                    SportsGroundView(model: selectedPlace)
                } label: {
                    Text("Загружаем карту ...")
                }
                MapViewUI(
                    viewKey: "SportsGroundsMapView",
                    region: $appState.mapRegion,
                    annotations: $appState.mapAnnotations,
                    selectedPlace: $selectedPlace,
                    openDetails: $openDetails
                )
            }
            .navigationTitle("Площадки")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SportsGroundsMapView_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundsMapView()
            .environmentObject(AppState())
    }
}
