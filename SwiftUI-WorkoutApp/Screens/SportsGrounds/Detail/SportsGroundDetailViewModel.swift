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
        if (isLoading || ground.isFull) && !refresh { return }
        if !refresh { isLoading.toggle() }
        do {
            ground = try await APIService(with: defaults).getSportsGround(id: ground.id)
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        if !refresh { isLoading.toggle() }
    }

    /// Меняем статус `trainHere`. При неудаче откатываем статус обратно.
    /// - Parameters:
    ///   - newValue: новое значение `trainHere`
    ///   - defaults: `UserDefaults` с необходимыми данными для операции
    func changeTrainHereStatus(_ newValue: Bool, with defaults: DefaultsService) async {
        if isLoading { return }
        let oldValue = ground.trainHere
        ground.trainHere = newValue
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).changeTrainHereStatus(newValue, for: ground.id) {
                if newValue, let userInfo = defaults.mainUserInfo {
                    ground.participants.append(userInfo)
                } else {
                    ground.participants.removeAll(where: { $0.userID == defaults.mainUserID })
                }
                defaults.setUserNeedUpdate(true)
            } else {
                ground.trainHere = oldValue
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
            ground.trainHere = oldValue
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
