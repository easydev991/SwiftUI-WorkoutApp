import Foundation

final class SportsGroundsService: ObservableObject {
    @Published var list = Bundle.main.decodeJson(
        [SportsGround].self,
        fileName: "areas.json"
    )
}
