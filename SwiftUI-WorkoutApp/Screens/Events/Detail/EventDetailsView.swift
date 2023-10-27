import FeedbackSender
import NetworkStatus
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран с детальной информацией о мероприятии
struct EventDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var isCreatingComment = false
    @State private var showDeleteDialog = false
    @State private var editComment: CommentResponse?
    @State private var goingToEventTask: Task<Void, Never>?
    @State private var deleteCommentTask: Task<Void, Never>?
    @State private var deletePhotoTask: Task<Void, Never>?
    @State private var deleteEventTask: Task<Void, Never>?
    @State private var refreshButtonTask: Task<Void, Never>?
    private let feedbackSender: FeedbackSender = FeedbackSenderImp()
    @State var event: EventResponse
    let onDeletion: (Int) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerAndMapSection
                if showParticipantSection {
                    participantsSection
                }
                if event.hasPhotos {
                    PhotoSectionView(
                        with: event.photos,
                        canDelete: isEventAuthor,
                        reportClbk: reportPhoto,
                        deleteClbk: deletePhoto
                    )
                }
                if event.hasDescription {
                    descriptionSection
                }
                authorSection
                if event.hasComments {
                    commentsSection
                }
            }
            .padding(.top, 8)
            .padding([.horizontal, .bottom])
        }
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .sheet(item: $editComment) {
            TextEntryView(
                mode: .editEvent(
                    .init(
                        parentObjectID: event.id,
                        entryID: $0.id,
                        oldEntry: $0.formattedBody
                    )
                ),
                refreshClbk: refreshAction
            )
        }
        .task { await askForInfo() }
        .refreshable { await askForInfo(refresh: true) }
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button("Ok") { alertMessage = "" }
        }
        .onChange(of: defaults.isAuthorized) { isAuth in
            if !isAuth { dismiss() }
        }
        .onDisappear(perform: cancelTasks)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isEventAuthor {
                    Group {
                        deleteButton
                        editEventButton
                    }
                    .disabled(isLoading || !network.isConnected)
                }
            }
        }
        .navigationTitle("Мероприятие")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension EventDetailsView {
    var headerAndMapSection: some View {
        let shortAddress = SWAddress(event.countryID, event.cityID)?.address ?? ""
        return VStack(spacing: 0) {
            Group {
                Text(event.formattedTitle)
                    .font(.title.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                SWDivider()
                    .padding(.top, 12)
                    .padding(.horizontal, -12)
                    .padding(.bottom, 10)
                HStack {
                    Text("Когда").font(.headline)
                    Spacer()
                    Text(event.eventDateString)
                }
                SWDivider()
                    .padding(.top, 10)
                    .padding(.horizontal, -12)
                    .padding(.bottom, 12)
                HStack {
                    Text("Где").font(.headline)
                    Spacer()
                    Text(shortAddress)
                }
                .padding(.bottom, 22)
            }
            .foregroundColor(.swMainText)
            SportsGroundLocationInfo(
                ground: $event.sportsGround,
                address: event.fullAddress ?? shortAddress,
                appleMapsURL: event.sportsGround.appleMapsURL
            )
        }
        .insideCardBackground()
    }

    var descriptionSection: some View {
        SectionView(headerWithPadding: "Описание", mode: .card(padding: 12)) {
            Text(.init(event.formattedDescription))
                .foregroundColor(.swMainText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .tint(.blue)
                .textSelection(.enabled)
        }
    }

    var participantsSection: some View {
        Group {
            if event.hasParticipants {
                NavigationLink {
                    UsersListView(mode: .eventParticipants(list: event.participants))
                } label: {
                    FormRowView(
                        title: "Участники",
                        trailingContent: .textWithChevron(
                            event.participantsCountString
                        )
                    )
                }
            }
            if event.isCurrent ?? false {
                FormRowView(
                    title: "Пойду на мероприятие",
                    trailingContent: .toggle(
                        .init(
                            get: { event.trainHere },
                            set: changeTrainHereStatus
                        )
                    )
                )
                .disabled(!network.isConnected)
            }
        }
    }

    func changeTrainHereStatus(newValue: Bool) {
        let oldValue = event.trainHere
        switch (oldValue, newValue) {
        case (true, true), (false, false):
            break // Пользователь не трогал тоггл
        case (true, false), (false, true):
            if isLoading { return }
            let oldValue = event.trainHere
            event.trainHere = newValue
            isLoading = true
            goingToEventTask = Task {
                do {
                    if try await SWClient(with: defaults).changeIsGoingToEvent(newValue, for: event.id) {
                        // Чтобы не делать лишнее обновление данных мероприятия,
                        // локально изменяем список участников
                        if newValue, let userInfo = defaults.mainUserInfo {
                            event.participants.append(userInfo)
                        } else {
                            event.participants.removeAll(where: { $0.userID == defaults.mainUserInfo?.userID })
                        }
                    } else {
                        event.trainHere = oldValue
                    }
                } catch {
                    setupErrorAlert(with: ErrorFilter.message(from: error))
                    event.trainHere = oldValue
                }
                isLoading = false
            }
        }
    }

    var authorSection: some View {
        let userModel = UserModel(event.author)
        return SectionView(headerWithPadding: "Организатор", mode: .regular) {
            NavigationLink(destination: UserDetailsView(for: event.author)) {
                UserRowView(
                    mode: .regular(
                        .init(
                            imageURL: userModel.imageURL,
                            name: userModel.name,
                            address: SWAddress(userModel.countryID, userModel.cityID).address
                        )
                    )
                )
            }
            .disabled(
                !defaults.isAuthorized
                    || isEventAuthor
                    || !network.isConnected
            )
        }
    }

    var commentsSection: some View {
        CommentsView(
            items: event.comments,
            reportClbk: reportComment,
            deleteClbk: deleteComment,
            editClbk: { editComment = $0 },
            isCreatingComment: $isCreatingComment
        )
        .sheet(isPresented: $isCreatingComment) {
            TextEntryView(
                mode: .newForEvent(id: event.id),
                refreshClbk: refreshAction
            )
        }
    }

    var deleteButton: some View {
        Button(action: { showDeleteDialog = true }) {
            Image(systemName: Icons.Regular.trash.rawValue)
        }
        .confirmationDialog(
            .init(Constants.Alert.deleteEvent),
            isPresented: $showDeleteDialog,
            titleVisibility: .visible
        ) {
            Button("Удалить", role: .destructive) {
                isLoading = true
                deleteEventTask = Task {
                    do {
                        if try await SWClient(with: defaults).delete(eventID: event.id) {
                            dismiss()
                            onDeletion(event.id)
                        }
                    } catch {
                        setupErrorAlert(with: ErrorFilter.message(from: error))
                    }
                    isLoading = false
                }
            }
        }
    }

    var editEventButton: some View {
        NavigationLink {
            EventFormView(for: .editExisting(event), refreshClbk: refreshAction)
        } label: {
            Image(systemName: Icons.Regular.pencil.rawValue)
        }
    }

    func refreshAction() {
        isCreatingComment = false
        editComment = nil
        refreshButtonTask = Task { await askForInfo(refresh: true) }
    }

    func askForInfo(refresh: Bool = false) async {
        if isLoading || event.isFull, !refresh { return }
        if !refresh { isLoading = true }
        do {
            event = try await SWClient(with: defaults, needAuth: defaults.isAuthorized)
                .getEvent(by: event.id)
        } catch {
            setupErrorAlert(with: ErrorFilter.message(from: error))
        }
        isLoading = false
    }

    func deleteComment(with id: Int) {
        if isLoading { return }
        isLoading = true
        deleteCommentTask = Task {
            do {
                if try await SWClient(with: defaults).deleteEntry(from: .event(id: event.id), entryID: id) {
                    event.comments.removeAll(where: { $0.id == id })
                }
            } catch {
                setupErrorAlert(with: ErrorFilter.message(from: error))
            }
            isLoading = false
        }
    }

    func deletePhoto(with id: Int) {
        if isLoading { return }
        isLoading = true
        deletePhotoTask = Task {
            do {
                if try await SWClient(with: defaults).deletePhoto(
                    from: .event(.init(containerID: event.id, photoID: id))
                ) {
                    event.photos.removeAll(where: { $0.id == id })
                }
            } catch {
                setupErrorAlert(with: ErrorFilter.message(from: error))
            }
            isLoading = false
        }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
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

    var isEventAuthor: Bool {
        defaults.isAuthorized
            ? event.authorID == defaults.mainUserInfo?.userID
            : false
    }

    var showParticipantSection: Bool {
        if defaults.isAuthorized {
            event.hasParticipants || event.isCurrent ?? false
        } else {
            false
        }
    }

    func cancelTasks() {
        [
            refreshButtonTask,
            deleteCommentTask,
            goingToEventTask,
            deletePhotoTask,
            deleteEventTask
        ].forEach { $0?.cancel() }
    }
}

#if DEBUG
#Preview {
    EventDetailsView(event: .preview, onDeletion: { _ in })
        .environmentObject(NetworkStatus())
        .environmentObject(DefaultsService())
}
#endif
