import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран с детальной информацией о мероприятии
struct EventDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.networkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var showDeleteDialog = false
    @State private var sheetItem: SheetItem?
    @State private var goingToEventTask: Task<Void, Never>?
    @State private var deleteCommentTask: Task<Void, Never>?
    @State private var deletePhotoTask: Task<Void, Never>?
    @State private var deleteEventTask: Task<Void, Never>?
    @State private var refreshButtonTask: Task<Void, Never>?
    /// Мероприятие для редактирования
    ///
    /// Задаем при нажатии на кнопку редактирования,
    /// чтобы в нем были актуальные данные
    @State private var eventToEdit: EventResponse?
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
                        reportClbk: { reportPhoto() },
                        deleteClbk: { deletePhoto(id: $0) }
                    )
                }
                if event.hasDescription {
                    descriptionSection
                }
                authorSection
                commentsSection
            }
            .padding(.top, 8)
            .padding([.horizontal, .bottom])
        }
        .background {
            NavigationLink(
                destination: lazyDestination,
                isActive: $eventToEdit.mappedToBool()
            )
        }
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .sheet(item: $sheetItem, content: makeSheetContent)
        .task { await askForInfo() }
        .refreshable { await askForInfo(refresh: true) }
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button("Ok") { alertMessage = "" }
        }
        .onDisappear(perform: cancelTasks)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CloseButton(mode: .text) { dismiss() }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isEventAuthor {
                    toolbarMenuButton
                }
                shareButton
            }
        }
        .navigationTitle("Мероприятие")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension EventDetailsView {
    enum SheetItem: Identifiable, Equatable {
        var id: Int {
            switch self {
            case .newComment: 1
            case .editComment: 2
            }
        }

        case newComment
        case editComment(CommentResponse)
    }
}

private extension EventDetailsView {
    var toolbarMenuButton: some View {
        Menu {
            Group {
                editEventButton
                deleteButton
            }
        } label: {
            Icons.Regular.ellipsis.view
                .symbolVariant(.circle)
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
                            onDeletion(event.id)
                        }
                    } catch {
                        setupErrorAlert(ErrorFilter.message(from: error))
                    }
                    isLoading = false
                }
            }
        }
        .disabled(isLoading || !isNetworkConnected)
    }

    var headerAndMapSection: some View {
        let shortAddress = SWAddress(event.countryID, event.cityID)?.address ?? ""
        return VStack(spacing: 0) {
            Group {
                Text(event.formattedTitle)
                    .font(.title2.weight(.semibold))
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
            .foregroundStyle(Color.swMainText)
            ParkLocationInfoView(
                snapshotModel: .init(
                    latitude: event.park.coordinate.latitude,
                    longitude: event.park.coordinate.longitude
                ),
                address: event.fullAddress ?? shortAddress,
                appleMapsURL: event.park.appleMapsURL
            )
        }
        .insideCardBackground()
    }

    var descriptionSection: some View {
        SectionView(headerWithPadding: "Описание", mode: .card(padding: 12)) {
            Text(.init(event.formattedDescription))
                .foregroundStyle(Color.swMainText)
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
                            set: { changeTrainHereStatus(newValue: $0) }
                        )
                    )
                )
                .disabled(!isNetworkConnected)
            }
        }
    }

    func changeTrainHereStatus(newValue: Bool) {
        let oldValue = event.trainHere
        switch (oldValue, newValue) {
        case (true, true), (false, false):
            break // Пользователь не трогал тоггл
        case (true, false), (false, true):
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
                            event.participants.removeAll(where: { $0.id == defaults.mainUserInfo?.id })
                        }
                    } else {
                        event.trainHere = oldValue
                    }
                } catch {
                    setupErrorAlert(ErrorFilter.message(from: error))
                    event.trainHere = oldValue
                }
                isLoading = false
            }
        }
    }

    var authorSection: some View {
        let user = event.author
        return SectionView(headerWithPadding: "Организатор", mode: .regular) {
            NavigationLink(destination: UserDetailsView(for: user)) {
                UserRowView(
                    mode: .regular(
                        .init(
                            imageURL: user?.avatarURL,
                            name: user?.userName ?? "",
                            address: SWAddress(user?.countryID, user?.cityID)?.address ?? ""
                        )
                    )
                )
            }
            .disabled(
                !defaults.isAuthorized
                    || isEventAuthor
                    || !isNetworkConnected
            )
        }
    }

    var commentsSection: some View {
        CommentsView(
            items: event.comments,
            reportClbk: reportComment,
            deleteClbk: deleteComment,
            editClbk: { sheetItem = .editComment($0) },
            isCreatingComment: .init(
                get: { sheetItem == .newComment },
                set: { newValue in
                    sheetItem = newValue ? .newComment : nil
                }
            )
        )
    }

    var deleteButton: some View {
        Button(role: .destructive, action: { showDeleteDialog = true }) {
            Label("Удалить", systemImage: Icons.Regular.trash.rawValue)
        }
    }

    var editEventButton: some View {
        Button { eventToEdit = event } label: {
            Label("Изменить", systemImage: Icons.Regular.pencil.rawValue)
        }
    }

    @ViewBuilder
    var lazyDestination: some View {
        if let eventToEdit {
            EventFormView(mode: .editExisting(eventToEdit), refreshClbk: refreshAction)
        }
    }

    @ViewBuilder
    var shareButton: some View {
        if #available(iOS 16.0, *), let url = event.shareLinkURL {
            ShareLink(
                item: url,
                subject: Text("Мероприятие"),
                message: Text(event.shareLinkDescription)
            )
        }
    }

    @ViewBuilder
    func makeSheetContent(for item: SheetItem) -> some View {
        switch item {
        case let .editComment(comment):
            TextEntryView(
                mode: .editEvent(
                    .init(
                        parentObjectID: event.id,
                        entryID: comment.id,
                        oldEntry: comment.formattedBody
                    )
                ),
                refreshClbk: refreshAction
            )
        case .newComment:
            TextEntryView(
                mode: .newForEvent(id: event.id),
                refreshClbk: refreshAction
            )
        }
    }

    func refreshAction() {
        sheetItem = nil
        refreshButtonTask = Task { await askForInfo(refresh: true) }
    }

    func askForInfo(refresh: Bool = false) async {
        if event.isFull, !refresh { return }
        if !refresh { isLoading = true }
        do {
            event = try await SWClient(with: defaults, needAuth: defaults.isAuthorized)
                .getEvent(by: event.id)
        } catch {
            setupErrorAlert(ErrorFilter.message(from: error))
        }
        isLoading = false
    }

    func deleteComment(with id: Int) {
        isLoading = true
        deleteCommentTask = Task {
            do {
                if try await SWClient(with: defaults).deleteEntry(from: .event(id: event.id), entryID: id) {
                    event.comments.removeAll(where: { $0.id == id })
                }
            } catch {
                setupErrorAlert(ErrorFilter.message(from: error))
            }
            isLoading = false
        }
    }

    func deletePhoto(id: Int) {
        isLoading = true
        deletePhotoTask = Task {
            do {
                if try await SWClient(with: defaults).deletePhoto(
                    from: .event(.init(containerID: event.id, photoID: id))
                ) {
                    event.photos.removeAll(where: { $0.id == id })
                }
            } catch {
                setupErrorAlert(ErrorFilter.message(from: error))
            }
            isLoading = false
        }
    }

    func setupErrorAlert(_ message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    func reportPhoto() {
        let complaint = Complaint.eventPhoto(eventTitle: event.formattedTitle)
        FeedbackSender.sendFeedback(
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
        FeedbackSender.sendFeedback(
            subject: complaint.subject,
            messageBody: complaint.body,
            recipients: Constants.feedbackRecipient
        )
    }

    var isEventAuthor: Bool {
        defaults.isAuthorized
            ? event.authorID == defaults.mainUserInfo?.id
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
        .environmentObject(DefaultsService())
}
#endif
