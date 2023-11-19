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
    @EnvironmentObject private var groundsManager: SportsGroundsManager
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var isCreatingComment = false
    @State private var isEditingGround = false
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
                commentsSection
            }
            .padding(.top, 8)
            .padding([.horizontal, .bottom])
        }
        .background {
            NavigationLink(isActive: $isEditingGround) {
                SportsGroundFormView(.editExisting(ground), refreshClbk: refreshAction)
            } label: {
                EmptyView()
            }
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
            ToolbarItem(placement: .topBarLeading) {
                Button("Закрыть") { dismiss() }
                    .accessibilityIdentifier("closeModalPageButton")
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isGroundAuthor {
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

private extension SportsGroundDetailView {
    var toolbarMenuButton: some View {
        Menu {
            Group {
                editGroundButton
                deleteButton
            }
        } label: {
            Icons.Regular.ellipsis.view
                .symbolVariant(.circle)
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
                            onDeletion(ground.id)
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
                Text(ground.shortTitle)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.swMainText)
                if let subtitle = ground.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .foregroundColor(.swSmallElements)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            SportsGroundLocationInfo(
                ground: ground,
                address: ground.address ?? "",
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
                            ground.participants.removeAll(where: { $0.id == defaults.mainUserInfo?.id })
                        }
                        defaults.setUserNeedUpdate(true)
                    } else {
                        ground.trainHere = oldValue
                    }
                } catch {
                    process(error)
                    ground.trainHere = oldValue
                }
                isLoading = false
            }
        }
    }

    var authorSection: some View {
        let user = ground.author
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
            Icons.Regular.exclamationArrowCircle.view
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

    @ViewBuilder
    var shareButton: some View {
        if #available(iOS 16.0, *), let url = ground.shareLinkURL {
            ShareLink(
                item: url,
                subject: Text("Площадка"),
                message: Text(ground.shareLinkDescription)
            )
        }
    }

    var deleteButton: some View {
        Button(role: .destructive, action: { dialogs.showDelete = true }) {
            Label("Удалить", systemImage: Icons.Regular.trash.rawValue)
        }
    }

    var editGroundButton: some View {
        Button { isEditingGround = true } label: {
            Label("Изменить", systemImage: Icons.Regular.pencil.rawValue)
        }
    }

    func refreshAction() {
        isCreatingComment = false
        editComment = nil
        refreshButtonTask = Task { await askForInfo(refresh: true) }
    }

    func askForInfo(refresh: Bool = false) async {
        if ground.isFull, !refresh { return }
        if !refresh { isLoading = true }
        do {
            ground = try await SWClient(with: defaults, needAuth: defaults.isAuthorized)
                .getSportsGround(id: ground.id)
        } catch {
            process(error)
        }
        isLoading = false
    }

    func deleteComment(with id: Int) {
        isLoading = true
        deleteCommentTask = Task {
            do {
                if try await SWClient(with: defaults).deleteEntry(from: .ground(id: ground.id), entryID: id) {
                    ground.comments.removeAll(where: { $0.id == id })
                }
            } catch {
                process(error)
            }
            isLoading = false
        }
    }

    func deletePhoto(with id: Int) {
        isLoading = true
        deletePhotoTask = Task {
            do {
                if try await SWClient(with: defaults).deletePhoto(
                    from: .sportsGround(.init(containerID: ground.id, photoID: id))
                ) {
                    ground.photos.removeAll(where: { $0.id == id })
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
            ? ground.authorID == defaults.mainUserInfo?.id
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

    func process(_ error: Error) {
        if error.localizedDescription.contains("404") {
            // Похоже, был запрос данных о несуществующей площадке
            // Удаляем её из памяти и закрываем экран
            try? groundsManager.deleteGround(with: ground.id)
            dismiss()
        } else {
            setupErrorAlert(ErrorFilter.message(from: error))
        }
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
        .environmentObject(SportsGroundsManager())
}
#endif
