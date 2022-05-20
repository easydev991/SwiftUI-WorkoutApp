//
//  SportsGroundsMapView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct SportsGroundsMapView: View {
    @EnvironmentObject private var sportsGrounds: SportsGroundsService
    @StateObject private var viewModel = SportsGroundsMapViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(isActive: $viewModel.openDetails) {
                    SportsGroundView(mode: .limited(id: viewModel.selectedPlace.id))
                } label: {
                    Text("Загружаем карту ...")
                }
                MapViewUI(
                    viewKey: "SportsGroundsMapView",
                    region: $viewModel.mapRegion,
                    annotations: $sportsGrounds.list,
                    selectedPlace: $viewModel.selectedPlace,
                    openDetails: $viewModel.openDetails
                )
            }
            .onAppear(perform: viewModel.onAppearAction)
            .onDisappear(perform: viewModel.onDisappearAction)
            .navigationTitle("Площадки")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SportsGroundsMapView_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundsMapView()
    }
}
