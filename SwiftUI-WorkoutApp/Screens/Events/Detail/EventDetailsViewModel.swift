import FeedbackSender
import Foundation
import SWModels
import SWNetworkClient

@MainActor
final class EventDetailsViewModel: ObservableObject {
    private let feedbackSender: FeedbackSender
    @Published var event: EventResponse
    @Published private(set) var isEventDeleted = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    var isEventCurrent: Bool { event.isCurrent.isTrue }
    var hasParticipants: Bool { !event.participants.isEmpty }
    var hasPhotos: Bool { !event.photos.isEmpty }

    init(with event: EventResponse) {
        self.event = event
        self.feedbackSender = FeedbackSenderImp()
    }

    func askForEvent(refresh: Bool, with defaults: DefaultsProtocol) async {
        if isLoading || event.isFull, !refresh { return }
        if !refresh { isLoading.toggle() }
        do {
            event = try await SWClient(with: defaults).getEvent(by: event.id)
        } catch {
            errorMessage = ErrorFilter.message(from: error)
        }
        if !refresh { isLoading.toggle() }
    }

    /// Меняем статус `trainHere`. При неудаче откатываем статус обратно.
    /// - Parameters:
    ///   - newValue: новое значение `trainHere`
    ///   - defaults: `UserDefaults` с необходимыми данными для операции
    func changeIsGoingToEvent(_ newValue: Bool, with defaults: DefaultsProtocol) async {
        if isLoading || !defaults.isAuthorized { return }
        let oldValue = event.trainHere
        event.trainHere = newValue
        isLoading.toggle()
        do {
            if try await SWClient(with: defaults).changeIsGoingToEvent(newValue, for: event.id) {
                if newValue, let userInfo = defaults.mainUserInfo {
                    event.participants.append(userInfo)
                } else {
                    event.participants.removeAll(where: { $0.userID == defaults.mainUserInfo?.userID })
                }
            } else {
                event.trainHere = oldValue
            }
        } catch {
            errorMessage = ErrorFilter.message(from: error)
            event.trainHere = oldValue
        }
        isLoading.toggle()
    }

    func delete(photoID: Int, with defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await SWClient(with: defaults).deletePhoto(
                from: .event(.init(containerID: event.id, photoID: photoID))
            ) {
                event.photos.removeAll(where: { $0.id == photoID })
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
            if try await SWClient(with: defaults).deleteEntry(from: .event(id: event.id), entryID: commentID) {
                event.comments.removeAll(where: { $0.id == commentID })
            }
        } catch {
            errorMessage = ErrorFilter.message(from: error)
        }
        isLoading.toggle()
    }

    func reportPhoto() {
        let complaint = Complaint.eventPhoto(eventTitle: event.formattedTitle)
        feedbackSender.sendFeedback(
            subject: complaint.subject,
            messageBody: complaint.body,
            recipients: Constants.feedbackRecipient
        )
    }

    func reportComment(_ comment: CommentResponse) {
        let complaint = Complaint.eventComment(
            eventTitle: event.formattedTitle,
            author: comment.user?.userName ?? "неизвестен",
            commentText: comment.formattedBody
        )
        feedbackSender.sendFeedback(
            subject: complaint.subject,
            messageBody: complaint.body,
            recipients: Constants.feedbackRecipient
        )
    }

    func deleteEvent(with defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            isEventDeleted = try await SWClient(with: defaults).delete(eventID: event.id)
        } catch {
            errorMessage = ErrorFilter.message(from: error)
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}
