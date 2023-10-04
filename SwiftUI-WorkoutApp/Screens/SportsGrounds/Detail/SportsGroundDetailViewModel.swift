import FeedbackSender
import Foundation
import SWModels
import SWNetworkClient

@MainActor
final class SportsGroundDetailViewModel: ObservableObject {
    private let feedbackSender: FeedbackSender
    @Published var ground: SportsGround
    @Published private(set) var isDeleted = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    var hasPhotos: Bool { !ground.photos.isEmpty }

    init(with ground: SportsGround) {
        self.ground = ground
        self.feedbackSender = FeedbackSenderImp()
    }

    func askForSportsGround(refresh: Bool, with defaults: DefaultsProtocol) async {
        if isLoading || ground.isFull, !refresh { return }
        if !refresh { isLoading.toggle() }
        do {
            ground = try await SWClient(with: defaults, needAuth: false).getSportsGround(id: ground.id)
        } catch {
            errorMessage = ErrorFilter.message(from: error)
        }
        if !refresh { isLoading.toggle() }
    }

    /// Меняем статус `trainHere`. При неудаче откатываем статус обратно.
    /// - Parameters:
    ///   - newValue: новое значение `trainHere`
    ///   - defaults: `UserDefaults` с необходимыми данными для операции
    func changeTrainHereStatus(_ newValue: Bool, with defaults: DefaultsProtocol) async {
        if isLoading { return }
        let oldValue = ground.trainHere
        ground.trainHere = newValue
        isLoading.toggle()
        do {
            if try await SWClient(with: defaults).changeTrainHereStatus(newValue, for: ground.id) {
                if newValue, let userInfo = defaults.mainUserInfo {
                    ground.participants.append(userInfo)
                } else {
                    ground.participants.removeAll(where: { $0.userID == defaults.mainUserInfo?.userID })
                }
                defaults.setUserNeedUpdate(true)
            } else {
                ground.trainHere = oldValue
            }
        } catch {
            errorMessage = ErrorFilter.message(from: error)
            ground.trainHere = oldValue
        }
        isLoading.toggle()
    }

    func delete(photoID: Int, with defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await SWClient(with: defaults).deletePhoto(
                from: .sportsGround(.init(containerID: ground.id, photoID: photoID))
            ) {
                ground.photos.removeAll(where: { $0.id == photoID })
            }
        } catch {
            errorMessage = ErrorFilter.message(from: error)
        }
        isLoading.toggle()
    }

    func delete(commentID: Int, with defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await SWClient(with: defaults).deleteEntry(from: .ground(id: ground.id), entryID: commentID) {
                ground.comments.removeAll(where: { $0.id == commentID })
            }
        } catch {
            errorMessage = ErrorFilter.message(from: error)
        }
        isLoading.toggle()
    }

    func reportPhoto() {
        let complaint = Complaint.groundPhoto(groundTitle: ground.shortTitle)
        feedbackSender.sendFeedback(
            subject: complaint.subject,
            messageBody: complaint.body,
            recipients: Constants.feedbackRecipient
        )
    }

    func reportComment(_ comment: CommentResponse) {
        let complaint = Complaint.groundComment(
            groundTitle: ground.shortTitle,
            author: comment.user?.userName ?? "неизвестен",
            commentText: comment.formattedBody
        )
        feedbackSender.sendFeedback(
            subject: complaint.subject,
            messageBody: complaint.body,
            recipients: Constants.feedbackRecipient
        )
    }

    func deleteGround(with defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            isDeleted = try await SWClient(with: defaults).delete(groundID: ground.id)
        } catch {
            errorMessage = ErrorFilter.message(from: error)
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}
