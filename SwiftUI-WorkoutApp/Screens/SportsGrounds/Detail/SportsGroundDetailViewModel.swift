import Foundation

final class SportsGroundDetailViewModel: ObservableObject {
    @Published var ground: SportsGround
    @Published private(set) var isDeleted = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    init(with ground: SportsGround) {
        self.ground = ground
    }

    @MainActor
    func askForSportsGround(refresh: Bool) async {
        if (isLoading || ground.isFull) && !refresh {
            return
        }
        if !refresh { isLoading.toggle() }
        do {
            ground = try await APIService().getSportsGround(id: ground.id)
        } catch {
            errorMessage = error.localizedDescription
        }
        if !refresh { isLoading.toggle() }
    }

    @MainActor
    func changeTrainHereStatus(with defaults: DefaultsService) async {
        if isLoading || !defaults.isAuthorized { return }
        isLoading.toggle()
        do {
            let trainHere = !ground.trainHere
            if try await APIService(with: defaults).changeTrainHereStatus(
                for: ground.id,
                trainHere: trainHere
            ) {
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

    @MainActor
    func delete(_ photo: Photo) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService().deletePhoto(from: .sportsGround(.init(containerID: ground.id, photoID: photo.id))) {
                await askForSportsGround(refresh: true)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    @MainActor
    func delete(commentID: Int, with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).deleteEntry(from: .ground(id: ground.id), entryID: commentID) {
                ground.comments.removeAll(where: { $0.id == commentID} )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    @MainActor
    func deleteGround(with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            isDeleted = try await APIService(with: defaults).delete(groundID: ground.id)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}
