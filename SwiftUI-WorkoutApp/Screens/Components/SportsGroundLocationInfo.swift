import SwiftUI

/// Содержит снапшот карты, адрес и ссылку на построение маршрута в `Apple Maps`
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
            if appleMapsURL != nil {
                Button {
                    if let url = appleMapsURL,
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Построить маршрут")
                        .blueMediumWeight()
                }
            }
        }
    }
}

struct SportsGroundLocationInfo_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            SportsGroundLocationInfo(
                ground: .constant(.mock),
                address: "Яблочная 15",
                appleMapsURL: .init(string: "maps://?saddr=&daddr=55.72681766162947,37.50063106774381")
            )
        }
    }
}
