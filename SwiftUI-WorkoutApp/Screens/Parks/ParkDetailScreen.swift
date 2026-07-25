import OSLog
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран с детальной информацией о площадке
struct ParkDetailScreen: View {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ParkDetailScreen")
    @Environment(\.analyticsService) private var analytics
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @State private var sheetItem: SheetItem?
    @State private var isLoading = false
    @State private var dialogs = ConfirmationDialogs()
    @State private var changeTrainHereTask: Task<Void, Never>?
    @State private var deleteCommentTask: Task<Void, Never>?
    @State private var deleteParkTask: Task<Void, Never>?
    @State private var deletePhotoTask: Task<Void, Never>?
    @State private var refreshButtonTask: Task<Void, Never>?
    @State var park: Park
    let onEdit: (_ updatedPark: Park) -> Void
    let onDelete: (_ parkId: Int) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerAndMapSection
                if defaults.isAuthorized {
                    participantsAndEventSection
                }
                if park.hasPhotos {
                    PhotoSectionView(
                        with: park.photos,
                        canDelete: canDeletePhoto,
                        reportClbk: { reportPhoto() },
                        deleteClbk: { deletePhoto(id: $0) }
                    )
                }
                authorSection
                commentsSection
            }
            .padding(.top, 8)
            .padding([.horizontal, .bottom])
        }
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .task { await askForInfo() }
        .refreshable { await askForInfo(refresh: true) }
        .sheet(item: $sheetItem, content: makeSheetContent)
        .onChange(of: defaults.isAuthorized) { isAuth in
            if !isAuth {
                dismiss()
            }
        }
        .onDisappear(perform: cancelTasks)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CloseButton(mode: .text) { dismiss() }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                Group {
                    if isParkAuthor {
                        toolbarMenuButton
                    } else {
                        feedbackButton
                    }
                    shareButton
                }
                .tint(.accent)
            }
        }
        .navigationTitle("Площадка")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(
            for: NavigationDestination.self,
            destination: makeDestinationView
        )
        .trackScreen(.parkDetail)
    }
}

private extension ParkDetailScreen {
    enum NavigationDestination: Hashable {
        case parkAuthor(UserResponse)
        case parkParticipants([UserResponse])
        case editPark(Park)
        case createEvent(_ parkId: Int, _ parkLongTitle: String)
    }

    enum SheetItem: Identifiable {
        var id: Int {
            switch self {
            case .createComment: 1
            case .editComment: 2
            }
        }

        case createComment(_ parkId: Int)
        case editComment(_ parkId: Int, _ commentId: Int, _ commentBody: String)
    }
}

private extension ParkDetailScreen {
    var toolbarMenuButton: some View {
        Menu {
            Group {
                editParkButton
                deleteButton
            }
        } label: {
            Icons.Regular.ellipsis.view
                .symbolVariant(.circle)
        }
        .confirmationDialog(
            Strings.Alert.deletePark,
            isPresented: $dialogs.showDelete,
            titleVisibility: .visible
        ) {
            Button("Удалить", role: .destructive) {
                analytics.log(.userAction(action: .deletePark))
                isLoading = true
                deleteParkTask = Task {
                    do {
                        #if DEBUG
                        let client: ParksClient = Constants.isUITest
                            ? MockSWClient(instantResponse: true)
                            : SWClient(with: defaults.authHelper)
                        #else
                        let client: ParksClient = SWClient(with: defaults.authHelper)
                        #endif
                        try await client.delete(parkId: park.id)
                        defaults.setUserNeedUpdate(true)
                        onDelete(park.id)
                    } catch {
                        analytics.log(.appError(kind: .parkDeleteFailed, error: error))
                        process(error)
                    }
                    isLoading = false
                }
            }
        }
        .opacity(isLoading ? 0 : 1)
    }

    var headerAndMapSection: some View {
        VStack(spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(park.shortTitle)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.swMainText)
                if !park.subtitle.isEmpty {
                    Text(park.subtitle)
                        .foregroundStyle(Color.swSmallElements)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            ParkLocationInfoView(
                snapshotModel: .init(
                    latitude: park.coordinate.latitude,
                    longitude: park.coordinate.longitude
                ),
                address: park.checkedAddress,
                appleMapsURL: park.appleMapsURL
            )
            if defaults.isAuthorized {
                NavigationLink(
                    "Создать мероприятие",
                    value: NavigationDestination.createEvent(park.id, park.longTitle)
                )
                .buttonStyle(SWButtonStyle(mode: .tinted, size: .large))
            }
        }
        .insideCardBackground()
    }

    var participantsAndEventSection: some View {
        Group {
            if park.hasParticipants {
                NavigationLink(value: NavigationDestination.parkParticipants(park.participants)) {
                    FormRowView(
                        title: "Здесь тренируются",
                        trailingContent: .textWithChevron(
                            park.participantsCountString
                        )
                    )
                }
            }
            FormRowView(
                title: "Тренируюсь здесь",
                trailingContent: .toggle(
                    .init(
                        get: { park.trainHere },
                        set: { changeTrainHereStatus(newValue: $0) }
                    )
                )
            )
        }
    }

    @ViewBuilder
    func makeDestinationView(for navigationDestination: NavigationDestination) -> some View {
        switch navigationDestination {
        case let .parkAuthor(user):
            UserDetailsScreen(for: user)
        case let .parkParticipants(users):
            ParticipantsScreen(mode: .park(list: users))
        case let .editPark(park):
            ParkFormScreen(.editExisting(park)) { newPark in
                self.park = newPark
                onEdit(newPark)
                sheetItem = nil
            }
        case let .createEvent(parkId, parkLongTitle):
            EventFormScreen(mode: .createForSelected(parkId, parkLongTitle))
        }
    }

    @ViewBuilder
    func makeSheetContent(for item: SheetItem) -> some View {
        switch item {
        case let .editComment(parkId, commentId, commentBody):
            TextEntryScreen(
                mode: .editPark(
                    .init(
                        parentObjectId: parkId,
                        entryId: commentId,
                        oldEntry: commentBody
                    )
                ),
                refreshClbk: refreshAction
            )
        case let .createComment(parkId):
            TextEntryScreen(
                mode: .newForPark(id: parkId),
                refreshClbk: refreshAction
            )
        }
    }

    func changeTrainHereStatus(newValue: Bool) {
        guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
        let oldValue = park.trainHere
        switch (oldValue, newValue) {
        case (true, true), (false, false):
            break // Пользователь не трогал тоггл
        case (true, false), (false, true):
            park.trainHere = newValue
            isLoading = true
            changeTrainHereTask = Task {
                do {
                    #if DEBUG
                    let client: ParksClient = Constants.isUITest
                        ? MockSWClient(instantResponse: true)
                        : SWClient(with: defaults.authHelper)
                    #else
                    let client: ParksClient = SWClient(with: defaults.authHelper)
                    #endif
                    try await client.changeTrainHereStatus(newValue, for: park.id)
                    // Чтобы не делать лишнее обновление данных площадки,
                    // локально изменяем список тренирующихся
                    if newValue, let userInfo = defaults.mainUserInfo {
                        park.participants.append(userInfo)
                    } else {
                        park.participants.removeAll(where: { $0.id == defaults.mainUserInfo?.id })
                    }
                    defaults.setUserNeedUpdate(true)
                } catch {
                    analytics.log(.appError(kind: .parkSaveFailed, error: error))
                    process(error)
                    park.trainHere = oldValue
                }
                isLoading = false
            }
        }
    }

    @ViewBuilder
    var authorSection: some View {
        if let user = park.author {
            SectionView(headerWithPadding: "Добавил", mode: .regular) {
                NavigationLink(value: NavigationDestination.parkAuthor(user)) {
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
                .disabled(!defaults.isAuthorized || isParkAuthor)
            }
        }
    }

    var commentsSection: some View {
        CommentsView(
            mainUserId: defaults.mainUserInfo?.id,
            items: park.comments,
            reportClbk: reportComment,
            deleteClbk: deleteComment,
            editClbk: {
                sheetItem = .editComment(park.id, $0.id, $0.formattedBody)
            },
            createCommentClbk: { sheetItem = .createComment(park.id) }
        )
    }

    var feedbackButton: some View {
        Button(action: { dialogs.showFeedback.toggle() }) {
            Icons.Regular.exclamationArrowCircle.view
        }
        .accessibilityLabel(Text("Сообщить об ошибке"))
        .confirmationDialog(
            .init(Strings.Alert.parkFeedback),
            isPresented: $dialogs.showFeedback,
            titleVisibility: .visible
        ) {
            Button("Написать письмо") {
                analytics.log(.userAction(action: .sendFeedback(source: .parkDetail)))
                FeedbackSender.sendFeedback(
                    subject: Feedback.makeSubject(for: park.shortTitle),
                    messageBody: Feedback.body,
                    recipients: Constants.feedbackRecipient
                )
            }
        }
    }

    @ViewBuilder
    var shareButton: some View {
        if let url = park.shareLinkURL {
            ShareLink(
                item: url,
                subject: Text("Площадка"),
                message: Text(park.shareLinkDescription)
            )
        }
    }

    var deleteButton: some View {
        Button(role: .destructive, action: { dialogs.showDelete = true }) {
            Label("Удалить", systemImage: Icons.Regular.trash.rawValue)
        }
    }

    var editParkButton: some View {
        NavigationLink(value: NavigationDestination.editPark(park)) {
            Label("Изменить", systemImage: Icons.Regular.pencil.rawValue)
        }
    }

    func refreshAction() {
        sheetItem = nil
        refreshButtonTask = Task { await askForInfo(refresh: true) }
    }

    func askForInfo(refresh: Bool = false) async {
        if park.isFull, !refresh {
            return
        }
        guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
        if !refresh {
            isLoading = true
        }
        do {
            #if DEBUG
            let client: ParksClient = Constants.isUITest
                ? MockSWClient(instantResponse: true)
                : SWClient(with: defaults.authHelper)
            #else
            let client: ParksClient = SWClient(with: defaults.authHelper)
            #endif
            park = try await client.getPark(id: park.id)
            if refresh {
                onEdit(park)
            }
        } catch {
            analytics.log(.appError(kind: .parkLoadFailed, error: error))
            process(error)
        }
        isLoading = false
    }

    func deleteComment(with id: Int) {
        guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
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
                try await client.deleteEntry(from: .park(id: park.id), entryId: id)
                park.comments.removeAll(where: { $0.id == id })
            } catch {
                process(error)
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
                    from: .park(.init(containerId: park.id, photoId: id))
                )
                park.photos = park.removePhotoById(id)
            } catch {
                process(error)
            }
            isLoading = false
        }
    }

    func reportPhoto() {
        analytics.log(.userAction(action: .reportPhoto(source: .parkDetail)))
        let complaint = Complaint.parkPhoto(parkTitle: park.shortTitle)
        FeedbackSender.sendFeedback(
            subject: complaint.subject,
            messageBody: complaint.body,
            recipients: Constants.feedbackRecipient
        )
    }

    func reportComment(_ comment: CommentResponse) {
        analytics.log(.userAction(action: .reportComment(source: .parkDetail)))
        let complaint = Complaint.parkComment(
            parkTitle: park.shortTitle,
            author: comment.user?.userName ?? "неизвестен",
            commentText: comment.formattedBody
        )
        FeedbackSender.sendFeedback(
            subject: complaint.subject,
            messageBody: complaint.body,
            recipients: Constants.feedbackRecipient
        )
    }

    var isParkAuthor: Bool {
        defaults.isAuthorized
            ? park.authorId == defaults.mainUserInfo?.id
            : false
    }

    var canDeletePhoto: Bool {
        isParkAuthor && park.photos.count > 1
    }

    func cancelTasks() {
        [
            refreshButtonTask,
            deleteCommentTask,
            changeTrainHereTask,
            deletePhotoTask,
            deleteParkTask
        ].forEach { $0?.cancel() }
    }

    func process(_ error: Error) {
        if let clientError = error as? ClientError, clientError == .notFound {
            logger.debug(
                """
                Похоже, был запрос данных о несуществующей площадке
                id площадки: \(park.id, privacy: .public)
                Удаляем ее из памяти и закрываем экран
                """
            )
            onDelete(park.id)
        } else {
            SWAlert.shared.presentDefaultUIKit(error)
        }
    }
}

private extension ParkDetailScreen {
    /// Содержит переключатели для диалогов на экране
    struct ConfirmationDialogs {
        /// Спросить об удалении площадки
        var showDelete = false
        /// Спросить о необходимости обновления площадки
        var showFeedback = false
    }

    enum Feedback {
        static func makeSubject(for parkNumber: String) -> String {
            "\(ProcessInfo.processInfo.processName): Обновление площадки \(parkNumber)"
        }

        static let body = """
            Какую информацию о площадке нужно обновить?
            \n
        """
    }
}

#if DEBUG
#Preview {
    ParkDetailScreen(park: .preview, onEdit: { _ in }, onDelete: { _ in })
        .environmentObject(DefaultsService(authHelper: MockAuthHelper()))
        .networkStatus(true)
}
#endif
