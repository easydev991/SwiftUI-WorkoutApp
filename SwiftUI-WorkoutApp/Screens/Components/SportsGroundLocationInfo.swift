//
//  SportsGroundLocationInfo.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 19.05.2022.
//

import SwiftUI

struct SportsGroundLocationInfo: View {
    @Binding var ground: SportsGround
    let address: String
    let appleMapsURL: URL?

    var body: some View {
        Section {
            MapSnapshotView(model: $ground)
                .frame(height: 150)
                .cornerRadius(8)
            Text(address)
            Button {
                if let url = appleMapsURL,
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Построить маршрут")
                    .blueMediumWeight()
            }
            .opacity(appleMapsURL == nil ? .zero : 1)
        }
    }
}

struct SportsGroundLocationInfo_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundLocationInfo(ground: .constant(.mock), address: "Яблочная 15", appleMapsURL: nil)
    }
}
