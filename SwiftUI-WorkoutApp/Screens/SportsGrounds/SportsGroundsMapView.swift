//
//  SportsGroundsMapView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct SportsGroundsMapView: View {
    @StateObject private var viewModel = SportsGroundsMapViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(isActive: $viewModel.openDetails) {
                    SportsGroundView(model: .init(with: viewModel.selectedPlace))
                } label: {
                    Text("Загружаем карту ...")
                }
                MapViewUI(
                    viewKey: "SportsGroundsMapView",
                    region: $viewModel.mapRegion,
                    annotations: $viewModel.mapAnnotations,
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
