import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels

/// Экран с детальной информацией о мероприятии
struct EventDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel: EventDetailsViewModel
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var isCreatingComment = false
    @State private var showDeleteDialog = false
    @State private var trainHere = false
    @State private var editComment: CommentResponse?
    @State private var goingToEventTask: Task<Void, Never>?
    @State private var deleteCommentTask: Task<Void, Never>?
    @State private var deletePhotoTask: Task<Void, Never>?
    @State private var deleteEventTask: Task<Void, Never>?
    @State private var refreshButtonTask: Task<Void, Never>?
    private let onDeletion: () -> Void

    init(
        with event: EventResponse,
        onDeletion: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: .init(with: event))
        self.onDeletion = onDeletion
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerAndMapSection
                if showParticipantSection {
                    participantsSection
                }
                if viewModel.hasPhotos {
                    PhotoSectionView(
                        with: viewModel.event.photos,
                        canDelete: isAuthor,
                        reportClbk: { viewModel.reportPhoto() },
                        deleteClbk: deletePhoto
                    )
                }
                if viewModel.event.hasDescription {
                    descriptionSection
                }
                authorSection
                if !viewModel.event.comments.isEmpty {
                    commentsSection
                }
            }
            .padding(.top, 8)
            .padding([.horizontal, .bottom])
        }
        .loadingOverlay(if: viewModel.isLoading)
        .background(Color.swBackground)
        .sheet(item: $editComment) {
            TextEntryView(
                mode: .editEvent(
                    .init(
                        parentObjectID: viewModel.event.id,
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
            Button("Ok", action: { viewModel.clearErrorMessage() })
        }
        .onReceive(viewModel.$event, perform: onReceiveOfEventSetupTrainHere)
        .onChange(of: viewModel.event.trainHere, perform: onChangeOfTrainHere)
        .onChange(of: viewModel.isEventDeleted, perform: dismissDeleted)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: defaults.isAuthorized, perform: dismissNotAuth)
        .onDisappear(perform: cancelTasks)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isAuthor, network.isConnected {
                    Group {
                        deleteButton
                        editEventButton
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
        .navigationTitle("Мероприятие")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension EventDetailsView {
    var headerAndMapSection: some View {
        VStack(spacing: 0) {
            Group {
                Text(viewModel.event.formattedTitle)
                    .font(.title.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                SWDivider()
                    .padding(.top, 12)
                    .padding(.horizontal, -12)
                    .padding(.bottom, 10)
                HStack {
                    Text("Когда").font(.headline)
                    Spacer()
                    Text(viewModel.event.eventDateString)
                }
                SWDivider()
                    .padding(.top, 10)
                    .padding(.horizontal, -12)
                    .padding(.bottom, 12)
                HStack {
                    Text("Где").font(.headline)
                    Spacer()
                    Text(viewModel.event.shortAddress)
                }
                .padding(.bottom, 22)
            }
            .foregroundColor(.swMainText)
            SportsGroundLocationInfo(
                ground: $viewModel.event.sportsGround,
                address: viewModel.event.fullAddress ?? viewModel.event.shortAddress,
                appleMapsURL: viewModel.event.sportsGround.appleMapsURL
            )
        }
        .insideCardBackground()
    }

    var descriptionSection: some View {
        SectionView(headerWithPadding: "Описание", mode: .card(padding: 12)) {
            Text(.init(viewModel.event.formattedDescription))
                .foregroundColor(.swMainText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .tint(.blue)
                .textSelection(.enabled)
        }
    }

    var participantsSection: some View {
        Group {
            if viewModel.hasParticipants {
                NavigationLink {
                    UsersListView(mode: .eventParticipants(list: viewModel.event.participants))
                } label: {
                    FormRowView(
                        title: "Участники",
                        trailingContent: .textWithChevron(
                            viewModel.event.participantsCountString
                        )
                    )
                }
            }
            if viewModel.isEventCurrent {
                FormRowView(
                    title: "Пойду на мероприятие",
                    trailingContent: .toggle($trainHere)
                )
                .disabled(!network.isConnected)
                .onChange(of: trainHere, perform: changeTrainHereStatus)
            }
        }
    }

    func changeTrainHereStatus(newValue: Bool) {
        let oldValue = viewModel.event.trainHere
        switch (oldValue, newValue) {
        case (true, true), (false, false):
            break // Пользователь не трогал тоггл
        case (true, false), (false, true):
            goingToEventTask = Task {
                await viewModel.changeIsGoingToEvent(newValue, with: defaults)
            }
        }
    }

    /// Настраиваем начальное состояние `trainHere` при появлении экрана
    func onReceiveOfEventSetupTrainHere(event: EventResponse) {
        trainHere = event.trainHere
    }

    /// Обновляем состояние `trainHere` при получении изменений от `viewModel`
    ///
    /// Например, если сервер вернул ошибку при попытке сменить статус
    func onChangeOfTrainHere(value: Bool) { trainHere = value }

    var authorSection: some View {
        let userModel = UserModel(viewModel.event.author)
        return SectionView(headerWithPadding: "Организатор", mode: .regular) {
            NavigationLink(destination: UserDetailsView(for: viewModel.event.author)) {
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
                    || viewModel.event.authorID == defaults.mainUserInfo?.userID
                    || !network.isConnected
            )
        }
    }

    var commentsSection: some View {
        CommentsView(
            items: viewModel.event.comments,
            reportClbk: { viewModel.reportComment($0) },
            deleteClbk: { id in
                deleteCommentTask = Task {
                    await viewModel.delete(commentID: id, with: defaults)
                }
            },
            editClbk: { editComment = $0 },
            isCreatingComment: $isCreatingComment
        )
        .sheet(isPresented: $isCreatingComment) {
            TextEntryView(
                mode: .newForEvent(id: viewModel.event.id),
                refreshClbk: refreshAction
            )
        }
    }

    func askForInfo(refresh: Bool = false) async {
        await viewModel.askForEvent(refresh: refresh, with: defaults)
    }

    func refreshAction() {
        refreshButtonTask = Task { await askForInfo(refresh: true) }
    }

    var deleteButton: some View {
        Button(action: { showDeleteDialog.toggle() }) {
            Image(systemName: "trash")
        }
        .confirmationDialog(
            Constants.Alert.deleteEvent,
            isPresented: $showDeleteDialog,
            titleVisibility: .visible
        ) {
            Button("Удалить", role: .destructive) {
                deleteEventTask = Task {
                    await viewModel.deleteEvent(with: defaults)
                }
            }
        }
    }

    var editEventButton: some View {
        NavigationLink {
            EventFormView(for: .editExisting(viewModel.event), refreshClbk: refreshAction)
        } label: {
            Image(systemName: Icons.Regular.pencil.rawValue)
        }
    }

    func deletePhoto(with id: Int) {
        deletePhotoTask = Task {
            await viewModel.delete(photoID: id, with: defaults)
        }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    var isAuthor: Bool {
        defaults.isAuthorized
            ? viewModel.event.authorID == defaults.mainUserInfo?.userID
            : false
    }

    var showParticipantSection: Bool {
        if defaults.isAuthorized {
            return viewModel.hasParticipants || viewModel.isEventCurrent
        } else {
            return false
        }
    }

    func dismissNotAuth(isAuth: Bool) {
        if !isAuth { dismiss() }
    }

    func dismissDeleted(isDeleted: Bool) {
        if isDeleted {
            dismiss()
            onDeletion()
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
    EventDetailsView(with: .preview, onDeletion: {})
        .environmentObject(NetworkStatus())
        .environmentObject(DefaultsService())
}
#endif
