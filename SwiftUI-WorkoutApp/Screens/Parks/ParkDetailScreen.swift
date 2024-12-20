import NetworkStatus
import OSLog
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран с детальной информацией о площадке
struct ParkDetailScreen: View {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ParkDetailScreen")
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var isCreatingComment = false
    @State private var isEditingPark = false
    @State private var editComment: CommentResponse?
    @State private var dialogs = ConfirmationDialogs()
    @State private var changeTrainHereTask: Task<Void, Never>?
    @State private var deleteCommentTask: Task<Void, Never>?
    @State private var deleteParkTask: Task<Void, Never>?
    @State private var deletePhotoTask: Task<Void, Never>?
    @State private var refreshButtonTask: Task<Void, Never>?
    @State var park: Park
    let onDeletion: (Int) -> Void

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
        .background {
            NavigationLink(isActive: $isEditingPark) {
                ParkFormScreen(.editExisting(park)) { refreshAction() }
            } label: {
                EmptyView()
            }
        }
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .sheet(item: $editComment) {
            TextEntryView(
                mode: .editPark(
                    .init(
                        parentObjectID: park.id,
                        entryID: $0.id,
                        oldEntry: $0.formattedBody
                    )
                ),
                refreshClbk: { refreshAction() }
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
            ToolbarItem(placement: .topBarLeading) {
                CloseButton(mode: .text) { dismiss() }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isParkAuthor {
                    toolbarMenuButton
                } else {
                    feedbackButton
                }
                shareButton
            }
        }
        .navigationTitle("Площадка")
        .navigationBarTitleDisplayMode(.inline)
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
            .init(Constants.Alert.deletePark),
            isPresented: $dialogs.showDelete,
            titleVisibility: .visible
        ) {
            Button("Удалить", role: .destructive) {
                isLoading = true
                deleteParkTask = Task {
                    do {
                        if try await SWClient(with: defaults).delete(parkID: park.id) {
                            defaults.setUserNeedUpdate(true)
                            onDeletion(park.id)
                        }
                    } catch {
                        process(error)
                    }
                    isLoading = false
                }
            }
        }
        .disabled(isLoading || !network.isConnected)
    }

    var headerAndMapSection: some View {
        VStack(spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(park.shortTitle)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.swMainText)
                if let subtitle = park.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .foregroundStyle(Color.swSmallElements)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            ParkLocationInfoView(
                snapshotModel: .init(
                    latitude: park.coordinate.latitude,
                    longitude: park.coordinate.longitude
                ),
                address: park.address ?? "",
                appleMapsURL: park.appleMapsURL
            )
            if defaults.isAuthorized {
                NavigationLink {
                    EventFormView(mode: .createForSelected(park.id, park.longTitle))
                } label: {
                    Text("Создать мероприятие")
                }
                .buttonStyle(SWButtonStyle(mode: .tinted, size: .large))
                .disabled(!network.isConnected)
            }
        }
        .insideCardBackground()
    }

    var participantsAndEventSection: some View {
        Group {
            if park.hasParticipants {
                NavigationLink {
                    UsersListView(
                        mode: .parkParticipants(
                            list: park.participants
                        )
                    )
                } label: {
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
            .disabled(!network.isConnected)
        }
    }

    func changeTrainHereStatus(newValue: Bool) {
        let oldValue = park.trainHere
        switch (oldValue, newValue) {
        case (true, true), (false, false):
            break // Пользователь не трогал тоггл
        case (true, false), (false, true):
            park.trainHere = newValue
            isLoading = true
            changeTrainHereTask = Task {
                do {
                    if try await SWClient(with: defaults).changeTrainHereStatus(newValue, for: park.id) {
                        // Чтобы не делать лишнее обновление данных площадки,
                        // локально изменяем список тренирующихся
                        if newValue, let userInfo = defaults.mainUserInfo {
                            park.participants.append(userInfo)
                        } else {
                            park.participants.removeAll(where: { $0.id == defaults.mainUserInfo?.id })
                        }
                        defaults.setUserNeedUpdate(true)
                    } else {
                        park.trainHere = oldValue
                    }
                } catch {
                    process(error)
                    park.trainHere = oldValue
                }
                isLoading = false
            }
        }
    }

    var authorSection: some View {
        let user = park.author
        return SectionView(headerWithPadding: "Добавил", mode: .regular) {
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
                    || isParkAuthor
                    || !network.isConnected
            )
        }
    }

    var commentsSection: some View {
        CommentsView(
            items: park.comments,
            reportClbk: reportComment,
            deleteClbk: deleteComment,
            editClbk: { editComment = $0 },
            isCreatingComment: $isCreatingComment
        )
        .sheet(isPresented: $isCreatingComment) {
            TextEntryView(mode: .newForPark(id: park.id)) { refreshAction() }
        }
    }

    var feedbackButton: some View {
        Button(action: { dialogs.showFeedback.toggle() }) {
            Icons.Regular.exclamationArrowCircle.view
        }
        .confirmationDialog(
            .init(Constants.Alert.parkFeedback),
            isPresented: $dialogs.showFeedback,
            titleVisibility: .visible
        ) {
            Button("Написать письмо") {
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
        if #available(iOS 16.0, *), let url = park.shareLinkURL {
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
        Button { isEditingPark = true } label: {
            Label("Изменить", systemImage: Icons.Regular.pencil.rawValue)
        }
    }

    func refreshAction() {
        isCreatingComment = false
        editComment = nil
        refreshButtonTask = Task { await askForInfo(refresh: true) }
    }

    func askForInfo(refresh: Bool = false) async {
        if park.isFull, !refresh { return }
        if !refresh { isLoading = true }
        do {
            park = try await SWClient(with: defaults, needAuth: defaults.isAuthorized)
                .getPark(id: park.id)
        } catch {
            process(error)
        }
        isLoading = false
    }

    func deleteComment(with id: Int) {
        isLoading = true
        deleteCommentTask = Task {
            do {
                if try await SWClient(with: defaults).deleteEntry(from: .park(id: park.id), entryID: id) {
                    park.comments.removeAll(where: { $0.id == id })
                }
            } catch {
                process(error)
            }
            isLoading = false
        }
    }

    func deletePhoto(id: Int) {
        isLoading = true
        deletePhotoTask = Task {
            do {
                if try await SWClient(with: defaults).deletePhoto(
                    from: .park(.init(containerID: park.id, photoID: id))
                ) {
                    park.photos.removeAll(where: { $0.id == id })
                }
            } catch {
                process(error)
            }
            isLoading = false
        }
    }

    func setupErrorAlert(_ message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    func reportPhoto() {
        let complaint = Complaint.parkPhoto(parkTitle: park.shortTitle)
        FeedbackSender.sendFeedback(
            subject: complaint.subject,
            messageBody: complaint.body,
            recipients: Constants.feedbackRecipient
        )
    }

    func reportComment(_ comment: CommentResponse) {
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
            ? park.authorID == defaults.mainUserInfo?.id
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
        if error.localizedDescription.contains("404") {
            logger.debug(
                """
                Похоже, был запрос данных о несуществующей площадке
                id площадки: \(park.id, privacy: .public)
                Удаляем ее из памяти и закрываем экран
                """
            )
            onDeletion(park.id)
        } else {
            setupErrorAlert(ErrorFilter.message(from: error))
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
    ParkDetailScreen(park: .preview, onDeletion: { _ in })
        .environmentObject(NetworkStatus())
        .environmentObject(DefaultsService())
}
#endif
