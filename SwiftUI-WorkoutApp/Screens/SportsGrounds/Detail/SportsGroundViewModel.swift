import Foundation

final class SportsGroundViewModel: ObservableObject {
    @Published var ground = SportsGround.emptyValue
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    var showRefreshButton: Bool {
        ground.id == .zero && !isLoading
    }

    @MainActor
    func makeSportsGroundInfo(groundID: Int, with defaults: DefaultsService, refresh: Bool = false) async {
        if (isLoading || ground.id != .zero) && !refresh {
            return
        }
        if !refresh { isLoading.toggle() }
        do {
            ground = try await APIService(with: defaults).getSportsGround(id: groundID)
        } catch {
            errorMessage = error.localizedDescription
        }
        if !refresh { isLoading.toggle() }
    }

    @MainActor
    func delete(groundID: Int, commentID: Int, with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).deleteComment(from: .ground(id: groundID), commentID: commentID) {
                ground.comments.removeAll(where: { $0.id == commentID} )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    @MainActor
    func changeTrainHereStatus(groundID: Int, trainHere: Bool, with defaults: DefaultsService) async {
        if isLoading || !defaults.isAuthorized { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).changeTrainHereStatus(for: groundID, trainHere: trainHere) {
                ground.trainHere = trainHere
                if trainHere, let userInfo = defaults.mainUserInfo {
                    ground.participants.append(userInfo)
                } else {
                    ground.participants.removeAll(where: { $0.userID == defaults.mainUserID })
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}
