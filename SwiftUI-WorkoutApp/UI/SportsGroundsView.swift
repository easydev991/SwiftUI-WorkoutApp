//
//  SportsGroundsView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI
import MapKit

struct SportsGroundsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            Map(
                coordinateRegion: $appState.mapRegion,
                interactionModes: .pan,
                showsUserLocation: true,
                annotationItems: appState.mapAnnotations(),
                annotationContent: { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        NavigationLink {
                            Text(item.name)
                        } label: {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                        }
                    }
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
            .environmentObject(AppState())
    }
}
