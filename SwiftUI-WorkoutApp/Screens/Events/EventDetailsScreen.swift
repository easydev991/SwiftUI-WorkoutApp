import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран с детальной информацией о мероприятии
struct EventDetailsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var calendarManager = CalendarManager()
    @State private var navigationDestination: NavigationDestination?
    @State private var sheetItem: SheetItem?
    @State private var isLoading = false
    @State private var showDeleteDialog = false
    @State private var goingToEventTask: Task<Void, Never>?
    @State private var deleteCommentTask: Task<Void, Never>?
    @State private var deletePhotoTask: Task<Void, Never>?
    @State private var deleteEventTask: Task<Void, Never>?
    @State private var refreshEventTask: Task<Void, Never>?
    @State var event: EventResponse
    let onDeletion: (Int) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerAndMapSection
                if defaults.isAuthorized {
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
                isActive: $navigationDestination.mappedToBool()
            )
        }
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .sheet(item: $sheetItem, content: makeSheetContent)
        .task { await askForInfo() }
        .refreshable { await askForInfo(refresh: true) }
        .onDisappear(perform: cancelTasks)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CloseButton(mode: .text) { dismiss() }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
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

private extension EventDetailsScreen {
    enum NavigationDestination {
        case eventAuthor(UserResponse)
        case eventParticipants([UserResponse])
        case editEvent(EventResponse)
        case commentAuthor(UserResponse)
    }

    enum SheetItem: Identifiable {
        var id: Int {
            switch self {
            case .newComment: 1
            case .editComment: 2
            }
        }

        case newComment(_ eventId: Int)
        case editComment(CommentResponse)
    }
}

private extension EventDetailsScreen {
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
                        SWAlert.shared.presentDefaultUIKit(error)
                    }
                    isLoading = false
                }
            }
        }
        .opacity(isLoading ? 0 : 1)
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
            if event.isCurrent == true {
                addToCalendarButton
            }
        }
        .insideCardBackground()
    }

    var addToCalendarButton: some View {
        Button("Добавить в календарь", action: calendarManager.requestAccess)
            .buttonStyle(SWButtonStyle(mode: .tinted, size: .large))
            .padding(.top, 12)
            .sheet(isPresented: $calendarManager.showCalendar) {
                EKEventEditViewControllerRepresentable(
                    eventStore: calendarManager.eventStore,
                    event: event
                )
            }
            .alert(
                "Необходимо разрешить полный доступ к календарю в настройках телефона",
                isPresented: $calendarManager.showSettingsAlert
            ) {
                Button("Отмена", role: .cancel) {}
                Button("Перейти") {
                    URLOpener.open(URL(string: UIApplication.openSettingsURLString))
                }
            }
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
                Button {
                    navigationDestination = .eventParticipants(event.participants)
                } label: {
                    FormRowView(
                        title: "Участники",
                        trailingContent: .textWithChevron(
                            event.participantsCountString
                        )
                    )
                }
            }
            if event.isCurrent == true {
                FormRowView(
                    title: "Пойду на мероприятие",
                    trailingContent: .toggle(
                        .init(
                            get: { event.trainHere },
                            set: { changeTrainHereStatus(newValue: $0) }
                        )
                    )
                )
            }
        }
    }

    func changeTrainHereStatus(newValue: Bool) {
        guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
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
                    SWAlert.shared.presentDefaultUIKit(error)
                    event.trainHere = oldValue
                }
                isLoading = false
            }
        }
    }

    @ViewBuilder
    var authorSection: some View {
        if let user = event.author {
            SectionView(headerWithPadding: "Организатор", mode: .regular) {
                Button {
                    navigationDestination = .eventAuthor(user)
                } label: {
                    UserRowView(
                        mode: .regular(
                            .init(
                                imageURL: user.avatarURL,
                                name: user.userName ?? "",
                                address: SWAddress(user.countryID, user.cityID)?.address ?? ""
                            )
                        )
                    )
                }
                .disabled(!defaults.isAuthorized || isEventAuthor)
            }
        }
    }

    var commentsSection: some View {
        CommentsView(
            mainUserId: defaults.mainUserInfo?.id,
            items: event.comments,
            reportClbk: reportComment,
            deleteClbk: deleteComment,
            editClbk: { sheetItem = .editComment($0) },
            createCommentClbk: { sheetItem = .newComment(event.id) },
            openProfile: {
                guard defaults.isAuthorized else { return }
                navigationDestination = .commentAuthor($0)
            }
        )
    }

    var deleteButton: some View {
        Button(role: .destructive, action: { showDeleteDialog = true }) {
            Label("Удалить", systemImage: Icons.Regular.trash.rawValue)
        }
    }

    var editEventButton: some View {
        Button { navigationDestination = .editEvent(event) } label: {
            Label("Изменить", systemImage: Icons.Regular.pencil.rawValue)
        }
    }

    @ViewBuilder
    var lazyDestination: some View {
        if let navigationDestination {
            switch navigationDestination {
            case let .eventAuthor(user), let .commentAuthor(user):
                UserDetailsScreen(for: user)
            case let .eventParticipants(users):
                ParticipantsScreen(mode: .event(list: users))
            case let .editEvent(eventToEdit):
                EventFormScreen(mode: .editExisting(eventToEdit), refreshClbk: refreshAction)
            }
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
            TextEntryScreen(
                mode: .editEvent(
                    .init(
                        parentObjectID: event.id,
                        entryID: comment.id,
                        oldEntry: comment.formattedBody
                    )
                ),
                refreshClbk: refreshAction
            )
        case let .newComment(eventId):
            TextEntryScreen(
                mode: .newForEvent(id: eventId),
                refreshClbk: refreshAction
            )
        }
    }

    func refreshAction() {
        sheetItem = nil
        refreshEventTask = Task { await askForInfo(refresh: true) }
    }

    func askForInfo(refresh: Bool = false) async {
        if event.isFull, !refresh { return }
        if !refresh { isLoading = true }
        do {
            event = try await SWClient(with: defaults).getEvent(by: event.id)
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
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
                SWAlert.shared.presentDefaultUIKit(error)
            }
            isLoading = false
        }
    }

    func deletePhoto(id: Int) {
        guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
        isLoading = true
        deletePhotoTask = Task {
            do {
                if try await SWClient(with: defaults).deletePhoto(
                    from: .event(.init(containerID: event.id, photoID: id))
                ) {
                    event.photos = event.removePhotoById(id)
                }
            } catch {
                SWAlert.shared.presentDefaultUIKit(error)
            }
            isLoading = false
        }
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

    func cancelTasks() {
        [
            refreshEventTask,
            deleteCommentTask,
            goingToEventTask,
            deletePhotoTask,
            deleteEventTask
        ].forEach { $0?.cancel() }
    }
}

#if DEBUG
#Preview {
    EventDetailsScreen(event: .preview, onDeletion: { _ in })
        .environmentObject(DefaultsService())
}
#endif
