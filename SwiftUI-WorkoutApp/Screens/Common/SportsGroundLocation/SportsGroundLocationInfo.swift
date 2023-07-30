import DesignSystem
import SwiftUI
import SWModels

/// Содержит снапшот карты, адрес и ссылку на построение маршрута в `Apple Maps`
struct SportsGroundLocationInfo: View {
    private let urlOpener: URLOpener
    private let address: String
    private let appleMapsURL: URL?
    @Binding private var ground: SportsGround

    init(
        urlOpener: URLOpener = URLOpenerImp(),
        ground: Binding<SportsGround>,
        address: String,
        appleMapsURL: URL?
    ) {
        self.urlOpener = urlOpener
        self._ground = ground
        self.address = address
        self.appleMapsURL = appleMapsURL
    }

    var body: some View {
        VStack(spacing: 12) {
            MapSnapshotView(ground: $ground)
                .frame(height: 153)
                .cornerRadius(8)
            Text(address)
                .font(.headline)
                .foregroundColor(.swMainText)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let url = appleMapsURL {
                Button {
                    urlOpener.open(url)
                } label: {
                    Text("Построить маршрут")
                }
                .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
            }
        }
    }
}

#if DEBUG
struct SportsGroundLocationInfo_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundLocationInfo(
            ground: .constant(.preview),
            address: "Краснодар, ул. Восточно-кругликовская",
            appleMapsURL: .init(string: "maps://?saddr=&daddr=55.72681766162947,37.50063106774381")
        )
        .padding()
    }
}
#endif
