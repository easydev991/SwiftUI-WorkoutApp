import SWDesignSystem
import SwiftUI
import SWModels

/// Содержит снапшот карты, адрес и ссылку на построение маршрута в `Apple Maps`
struct SportsGroundLocationInfo: View {
    let snapshotModel: MapSnapshotView.Model
    let address: String
    let appleMapsURL: URL?

    var body: some View {
        VStack(spacing: 12) {
            MapSnapshotView(model: snapshotModel)
                .frame(height: 153)
                .cornerRadius(8)
            if !address.isEmpty {
                Text(address)
                    .font(.headline)
                    .foregroundColor(.swMainText)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if let url = appleMapsURL {
                Button {
                    URLOpener.open(url)
                } label: {
                    Text("Построить маршрут")
                }
                .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
            }
        }
    }
}

#if DEBUG
#Preview {
    SportsGroundLocationInfo(
        snapshotModel: .init(
            latitude: SportsGround.preview.coordinate.latitude,
            longitude: SportsGround.preview.coordinate.longitude
        ),
        address: "Краснодар, ул. Восточно-кругликовская",
        appleMapsURL: .init(string: "maps://?saddr=&daddr=55.72681766162947,37.50063106774381")
    )
    .padding()
}
#endif
