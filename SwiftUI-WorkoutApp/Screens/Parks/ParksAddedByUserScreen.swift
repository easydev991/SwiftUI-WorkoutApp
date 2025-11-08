import SWDesignSystem
import SwiftUI
import SWModels
import SWUtils

struct ParksAddedByUserScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @EnvironmentObject private var parksManager: ParksManager
    /// Площадка для открытия детального экрана
    @State private var selectedPark: Park?
    @State private var parkList: [Park] = []

    private let parkIds: [Int]

    init(parks: [Park]) {
        self.parkIds = parks.map(\.id)
    }

    var body: some View {
        List(parkList) { park in
            ParkRowItemView(
                imageURL: park.previewImageURL,
                title: park.longTitle,
                address: park.address,
                usersTrainHereText: park.usersTrainHereText,
                action: { selectedPark = park }
            )
        }
        .listStyle(.plain)
        .padding(.vertical)
        .task {
            do {
                parkList = try await parksManager.getParks(ids: parkIds)
            } catch {
                parkList = []
            }
        }
        .onChange(of: parkList) { updatedParks in
            if updatedParks.isEmpty { dismiss() }
        }
        .sheet(item: $selectedPark) { park in
            NavigationStack {
                ParkDetailScreen(
                    park: park,
                    onEdit: updatePark,
                    onDelete: deletePark
                )
            }
        }
        .background(Color.swBackground)
        .navigationTitle("Добавленные")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension ParksAddedByUserScreen {
    func deletePark(id: Int) {
        selectedPark = nil
        do {
            try parksManager.deletePark(with: id)
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
        }
    }

    func updatePark(_ park: Park) {
        do {
            try parksManager.manuallyUpdatePark(park)
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
        }
    }
}

#if DEBUG
#Preview {
    ParksAddedByUserScreen(parks: [.preview])
        .environmentObject(DefaultsService())
        .environmentObject(ParksManager())
}
#endif
