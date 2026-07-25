import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран с детальной информацией о мероприятии
struct EventDetailsScreen: View {
    @Environment(\.analyticsService) private var analytics
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var calendarManager = CalendarManager()
    @State private var sheetItem: SheetItem?
    @State private var isLoading = false
    @State private var showDeleteDialog = false
    @State private var goingToEventTask: Task<Void, Never>?
    @State private var deleteCommentTask: Task<Void, Never>?
    @State private var deletePhotoTask: Task<Void, Never>?
    @State private var deleteEventTask: Task<Void, Never>?
    @State private var refreshEventTask: Task<Void, Never>?
    @State var event: EventResponse
    let onDelete: (Int) -> Void

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
                Group {
                    if isEventAuthor {
                        toolbarMenuButton
                    }
                    shareButton
                }
                .tint(.accent)
            }
        }
        .navigationTitle(.event)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(
            for: NavigationDestination.self,
            destination: makeDestinationView
        )
        .trackScreen(.eventDetail)
    }
}

private extension EventDetailsScreen {
    enum NavigationDestination: Hashable {
        case eventAuthor(UserResponse)
        case eventParticipants([UserResponse])
        case editEvent(EventResponse)
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
            Strings.Alert.deleteEvent,
            isPresented: $showDeleteDialog,
            titleVisibility: .visible
        ) {
            Button("Удалить", role: .destructive) {
                analytics.log(.userAction(action: .deleteEvent))
                isLoading = true
                deleteEventTask = Task {
                    do {
                        #if DEBUG
                        let client: EventsClient = Constants.isUITest
                            ? MockSWClient(instantResponse: true)
                            : SWClient(with: defaults.authHelper)
                        #else
                        let client: EventsClient = SWClient(with: defaults.authHelper)
                        #endif
                        try await client.delete(eventId: event.id)
                        onDelete(event.id)
                    } catch {
                        analytics.log(.appError(kind: .eventDeleteFailed, error: error))
                        SWAlert.shared.presentDefaultUIKit(error)
                    }
                    isLoading = false
                }
            }
        }
        .opacity(isLoading ? 0 : 1)
    }

    var headerAndMapSection: some View {
        let shortAddress = SWAddress(event.countryId, event.cityId)?.address ?? ""
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
        Button("Добавить в календарь") {
            Task {
                do {
                    try await calendarManager.requestAccess()
                } catch {
                    SWAlert.shared.presentDefaultUIKit(error)
                }
            }
        }
        .buttonStyle(SWButtonStyle(mode: .tinted, size: .large))
        .padding(.top, 12)
        .sheet(isPresented: $calendarManager.showCalendar) {
            EKEventEditViewControllerRepresentable(
                eventStore: calendarManager.eventStore,
                event: event
            )
        }
        .alert(
            "Необходимо разрешить доступ к календарю в настройках телефона",
            isPresented: $calendarManager.showSettingsAlert
        ) {
            Button(.cancel, role: .cancel) {}
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
                NavigationLink(value: NavigationDestination.eventParticipants(event.participants)) {
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
                    #if DEBUG
                    let client: EventsClient = Constants.isUITest
                        ? MockSWClient(instantResponse: true)
                        : SWClient(with: defaults.authHelper)
                    #else
                    let client: EventsClient = SWClient(with: defaults.authHelper)
                    #endif
                    try await client.changeIsGoingToEvent(newValue, for: event.id)
                    // Чтобы не делать лишнее обновление данных мероприятия,
                    // локально изменяем список участников
                    if newValue, let userInfo = defaults.mainUserInfo {
                        event.participants.append(userInfo)
                    } else {
                        event.participants.removeAll(where: { $0.id == defaults.mainUserInfo?.id })
                    }
                } catch {
                    analytics.log(.appError(kind: .eventSaveFailed, error: error))
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
                NavigationLink(value: NavigationDestination.eventAuthor(user)) {
                    UserRowView(
                        mode: .regular(
                            .init(
                                imageURL: user.avatarURL,
                                name: user.userName ?? "",
                                address: SWAddress(user.countryId, user.cityId)?.address ?? ""
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
            createCommentClbk: { sheetItem = .newComment(event.id) }
        )
    }

    var deleteButton: some View {
        Button(role: .destructive, action: { showDeleteDialog = true }) {
            Label("Удалить", systemImage: Icons.Regular.trash.rawValue)
        }
    }

    var editEventButton: some View {
        NavigationLink(value: NavigationDestination.editEvent(event)) {
            Label("Изменить", systemImage: Icons.Regular.pencil.rawValue)
        }
    }

    @ViewBuilder
    func makeDestinationView(for navigationDestination: NavigationDestination) -> some View {
        switch navigationDestination {
        case let .eventAuthor(user):
            UserDetailsScreen(for: user)
        case let .eventParticipants(users):
            ParticipantsScreen(mode: .event(list: users))
        case let .editEvent(eventToEdit):
            EventFormScreen(mode: .editExisting(eventToEdit), refreshClbk: refreshAction)
        }
    }

    @ViewBuilder
    var shareButton: some View {
        if let url = event.shareLinkURL {
            ShareLink(
                item: url,
                subject: Text(.event),
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
                        parentObjectId: event.id,
                        entryId: comment.id,
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
        if event.isFull, !refresh {
            return
        }
        guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
        if !refresh {
            isLoading = true
        }
        do {
            #if DEBUG
            let client: EventsClient = Constants.isUITest
                ? MockSWClient(instantResponse: true)
                : SWClient(with: defaults.authHelper)
            #else
            let client: EventsClient = SWClient(with: defaults.authHelper)
            #endif
            event = try await client.getEvent(by: event.id)
        } catch {
            analytics.log(.appError(kind: .eventLoadFailed, error: error))
            SWAlert.shared.presentDefaultUIKit(error)
        }
        isLoading = false
    }

    func deleteComment(with id: Int) {
        isLoading = true
        deleteCommentTask = Task {
            do {
                #if DEBUG
                let client: CommentsClient = Constants.isUITest
                    ? MockSWClient(instantResponse: true)
                    : SWClient(with: defaults.authHelper)
                #else
                let client: CommentsClient = SWClient(with: defaults.authHelper)
                #endif
                try await client.deleteEntry(from: .event(id: event.id), entryId: id)
                event.comments.removeAll(where: { $0.id == id })
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
                #if DEBUG
                let client: PhotosClient = Constants.isUITest
                    ? MockSWClient(instantResponse: true)
                    : SWClient(with: defaults.authHelper)
                #else
                let client: PhotosClient = SWClient(with: defaults.authHelper)
                #endif
                try await client.deletePhoto(
                    from: .event(.init(containerId: event.id, photoId: id))
                )
                event.photos = event.removePhotoById(id)
            } catch {
                SWAlert.shared.presentDefaultUIKit(error)
            }
            isLoading = false
        }
    }

    func reportPhoto() {
        analytics.log(.userAction(action: .reportPhoto(source: .eventDetail)))
        let complaint = Complaint.eventPhoto(eventTitle: event.formattedTitle)
        FeedbackSender.sendFeedback(
            subject: complaint.subject,
            messageBody: complaint.body,
            recipients: Constants.feedbackRecipient
        )
    }

    func reportComment(_ comment: CommentResponse) {
        analytics.log(.userAction(action: .reportComment(source: .eventDetail)))
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
            ? event.authorId == defaults.mainUserInfo?.id
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
    EventDetailsScreen(event: .preview, onDelete: { _ in })
        .environmentObject(DefaultsService(authHelper: MockAuthHelper()))
}
#endif
