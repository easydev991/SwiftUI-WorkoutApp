import FeedbackSender
import NetworkStatus
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран с детальной информацией о площадке
struct SportsGroundDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var isCreatingComment = false
    @State private var editComment: CommentResponse?
    @State private var dialogs = ConfirmationDialogs()
    @State private var changeTrainHereTask: Task<Void, Never>?
    @State private var deleteCommentTask: Task<Void, Never>?
    @State private var deleteGroundTask: Task<Void, Never>?
    @State private var deletePhotoTask: Task<Void, Never>?
    @State private var refreshButtonTask: Task<Void, Never>?
    private let feedbackSender: FeedbackSender = FeedbackSenderImp()
    @State var ground: SportsGround
    let onDeletion: (Int) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerAndMapSection
                if defaults.isAuthorized {
                    participantsAndEventSection
                }
                if ground.hasPhotos {
                    PhotoSectionView(
                        with: ground.photos,
                        canDelete: isGroundAuthor,
                        reportClbk: reportPhoto,
                        deleteClbk: deletePhoto
                    )
                }
                authorSection
                if ground.hasComments {
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
                mode: .editGround(
                    .init(
                        parentObjectID: ground.id,
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
                if isGroundAuthor {
                    Group {
                        deleteButton
                        editGroundButton
                    }
                    .disabled(isLoading || !network.isConnected)
                } else {
                    feedbackButton
                        .disabled(isLoading)
                }
            }
        }
        .navigationTitle("Площадка")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension SportsGroundDetailView {
    var headerAndMapSection: some View {
        VStack(spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(ground.shortTitle)
                    .font(.title.bold())
                    .foregroundColor(.swMainText)
                Spacer()
                Text(ground.subtitle.valueOrEmpty)
                    .foregroundColor(.swSmallElements)
            }
            SportsGroundLocationInfo(
                ground: $ground,
                address: ground.address.valueOrEmpty,
                appleMapsURL: ground.appleMapsURL
            )
            if defaults.isAuthorized {
                NavigationLink {
                    EventFormView(for: .createForSelected(ground))
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
            if ground.hasParticipants {
                NavigationLink {
                    UsersListView(
                        mode: .groundParticipants(
                            list: ground.participants
                        )
                    )
                } label: {
                    FormRowView(
                        title: "Здесь тренируются",
                        trailingContent: .textWithChevron(
                            ground.participantsCountString
                        )
                    )
                }
            }
            FormRowView(
                title: "Тренируюсь здесь",
                trailingContent: .toggle(
                    .init(
                        get: { ground.trainHere },
                        set: changeTrainHereStatus
                    )
                )
            )
            .disabled(!network.isConnected)
        }
    }

    func changeTrainHereStatus(newValue: Bool) {
        let oldValue = ground.trainHere
        switch (oldValue, newValue) {
        case (true, true), (false, false):
            break // Пользователь не трогал тоггл
        case (true, false), (false, true):
            if isLoading { return }
            let oldValue = ground.trainHere
            ground.trainHere = newValue
            isLoading = true
            changeTrainHereTask = Task {
                do {
                    if try await SWClient(with: defaults).changeTrainHereStatus(newValue, for: ground.id) {
                        // Чтобы не делать лишнее обновление данных площадки,
                        // локально изменяем список тренирующихся
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
                    setupErrorAlert(with: ErrorFilter.message(from: error))
                    ground.trainHere = oldValue
                }
                isLoading = false
            }
        }
    }

    var authorSection: some View {
        let userModel = UserModel(ground.author)
        return SectionView(headerWithPadding: "Добавил", mode: .regular) {
            NavigationLink(destination: UserDetailsView(for: ground.author)) {
                UserRowView(
                    mode: .regular(
                        .init(
                            imageURL: userModel.imageURL,
                            name: userModel.name,
                            address: userModel.shortAddress
                        )
                    )
                )
            }
            .disabled(
                !defaults.isAuthorized
                    || isGroundAuthor
                    || !network.isConnected
            )
        }
    }

    var commentsSection: some View {
        CommentsView(
            items: ground.comments,
            reportClbk: reportComment,
            deleteClbk: deleteComment,
            editClbk: { editComment = $0 },
            isCreatingComment: $isCreatingComment
        )
        .sheet(isPresented: $isCreatingComment) {
            TextEntryView(
                mode: .newForGround(id: ground.id),
                refreshClbk: refreshAction
            )
        }
    }

    var feedbackButton: some View {
        Button(action: { dialogs.showFeedback.toggle() }) {
            Image(systemName: Icons.Regular.exclamationArrowCircle.rawValue)
        }
        .confirmationDialog(
            .init(Constants.Alert.groundFeedback),
            isPresented: $dialogs.showFeedback,
            titleVisibility: .visible
        ) {
            Button("Написать письмо") {
                feedbackSender.sendFeedback(
                    subject: Feedback.makeSubject(for: ground.shortTitle),
                    messageBody: Feedback.body,
                    recipients: Constants.feedbackRecipient
                )
            }
        }
    }

    var deleteButton: some View {
        Button(action: { dialogs.showDelete = true }) {
            Image(systemName: Icons.Regular.trash.rawValue)
        }
        .confirmationDialog(
            .init(Constants.Alert.deleteGround),
            isPresented: $dialogs.showDelete,
            titleVisibility: .visible
        ) {
            Button("Удалить", role: .destructive) {
                isLoading = true
                deleteGroundTask = Task {
                    do {
                        if try await SWClient(with: defaults).delete(groundID: ground.id) {
                            defaults.setUserNeedUpdate(true)
                            dismiss()
                            onDeletion(ground.id)
                        }
                    } catch {
                        setupErrorAlert(with: ErrorFilter.message(from: error))
                    }
                    isLoading = false
                }
            }
        }
    }

    var editGroundButton: some View {
        NavigationLink {
            SportsGroundFormView(.editExisting(ground), refreshClbk: refreshAction)
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
        if isLoading || ground.isFull, !refresh { return }
        if !refresh { isLoading = true }
        do {
            ground = try await SWClient(with: defaults, needAuth: defaults.isAuthorized)
                .getSportsGround(id: ground.id)
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
                if try await SWClient(with: defaults).deleteEntry(from: .ground(id: ground.id), entryID: id) {
                    ground.comments.removeAll(where: { $0.id == id })
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
                    from: .sportsGround(.init(containerID: ground.id, photoID: id))
                ) {
                    ground.photos.removeAll(where: { $0.id == id })
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

    var isGroundAuthor: Bool {
        defaults.isAuthorized
            ? ground.authorID == defaults.mainUserInfo?.userID
            : false
    }

    func cancelTasks() {
        [
            refreshButtonTask,
            deleteCommentTask,
            changeTrainHereTask,
            deletePhotoTask,
            deleteGroundTask
        ].forEach { $0?.cancel() }
    }
}

private extension SportsGroundDetailView {
    /// Содержит переключатели для диалогов на экране
    struct ConfirmationDialogs {
        /// Спросить об удалении площадки
        var showDelete = false
        /// Спросить о необходимости обновления площадки
        var showFeedback = false
    }

    enum Feedback {
        static func makeSubject(for groundNumber: String) -> String {
            "\(ProcessInfo.processInfo.processName): Обновление площадки \(groundNumber)"
        }

        static let body = """
            Какую информацию о площадке нужно обновить?
            \n
        """
    }
}

#if DEBUG
#Preview {
    SportsGroundDetailView(ground: .preview, onDeletion: { _ in })
        .environmentObject(NetworkStatus())
        .environmentObject(DefaultsService())
}
#endif
