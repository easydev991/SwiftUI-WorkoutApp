import SwiftUI

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
        Section {
            MapSnapshotView(ground: $ground)
                .cornerRadius(8)
                .frame(height: 150)
            Text(address)
            if let url = appleMapsURL {
                Button {
                    urlOpener.open(url)
                } label: {
                    Text("Построить маршрут")
                        .blueMediumWeight()
                }
            }
        }
    }
}

#if DEBUG
struct SportsGroundLocationInfo_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            SportsGroundLocationInfo(
                ground: .constant(.preview),
                address: "Яблочная 15",
                appleMapsURL: .init(string: "maps://?saddr=&daddr=55.72681766162947,37.50063106774381")
            )
        }
    }
}
#endif
