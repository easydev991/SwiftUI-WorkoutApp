import SWDesignSystem
import SwiftUI
import SWModels

/// Содержит снапшот карты, адрес и ссылку на построение маршрута в `Apple Maps`
struct ParkLocationInfoView: View {
    @MainActor
    private var screenWidth: CGFloat { UIScreen.main.bounds.size.width }
    let snapshotModel: MapSnapshotView.MapModel
    let address: String
    let appleMapsURL: URL?

    var body: some View {
        VStack(spacing: 12) {
            MapSnapshotView(
                mapModel: snapshotModel,
                size: .init(
                    width: screenWidth - 24 - 32, // 2 * 12 и 2 * 16 - отступы по бокам в фигме
                    height: 153
                )
            )
            .cornerRadius(8)
            if !address.isEmpty {
                Text(address)
                    .font(.headline)
                    .foregroundStyle(Color.swMainText)
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
    ParkLocationInfoView(
        snapshotModel: .init(
            latitude: Park.preview.coordinate.latitude,
            longitude: Park.preview.coordinate.longitude
        ),
        address: "Краснодар, ул. Восточно-кругликовская",
        appleMapsURL: .init(string: "maps://?saddr=&daddr=55.72681766162947,37.50063106774381")
    )
    .padding()
}
#endif
