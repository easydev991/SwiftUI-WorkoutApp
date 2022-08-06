import Foundation

@MainActor
final class SportsGroundDetailViewModel: ObservableObject {
    @Published var ground: SportsGround
    @Published private(set) var isDeleted = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    init(with ground: SportsGround) {
        self.ground = ground
    }

    func askForSportsGround(refresh: Bool, with defaults: DefaultsService) async {
        if (isLoading || ground.isFull) && !refresh {
            return
        }
        if !refresh { isLoading.toggle() }
        do {
            ground = try await APIService(with: defaults).getSportsGround(id: ground.id)
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        if !refresh { isLoading.toggle() }
    }

    func changeTrainHereStatus(with defaults: DefaultsService) async {
        if isLoading { return }
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
                defaults.setUserNeedUpdate(true)
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func delete(_ photo: Photo, with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).deletePhoto(
                from: .sportsGround(.init(containerID: ground.id, photoID: photo.id))
            ) {
                await askForSportsGround(refresh: true, with: defaults)
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func delete(commentID: Int, with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).deleteEntry(from: .ground(id: ground.id), entryID: commentID) {
                ground.comments.removeAll(where: { $0.id == commentID} )
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func deleteGround(with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            isDeleted = try await APIService(with: defaults).delete(groundID: ground.id)
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}
