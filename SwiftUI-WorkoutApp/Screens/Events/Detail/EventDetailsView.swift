import SwiftUI

/// Экран с детальной информацией о мероприятии
struct EventDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var network: CheckNetworkService
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel: EventDetailsViewModel
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var isCreatingComment = false
    @State private var showDeleteDialog = false
    @State private var trainHere = false
    @State private var editComment: Comment?
    @State private var goingToEventTask: Task<Void, Never>?
    @State private var deleteCommentTask: Task<Void, Never>?
    @State private var deletePhotoTask: Task<Void, Never>?
    @State private var deleteEventTask: Task<Void, Never>?
    @State private var refreshButtonTask: Task<Void, Never>?
    private let onDeletion: () -> Void

    init(
        with event: EventResponse,
        deleteClbk: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: .init(with: event))
        onDeletion = deleteClbk
    }

    var body: some View {
        Form {
            mainInfo
            locationInfo
            if viewModel.event.hasDescription {
                descriptionSection
            }
            if defaults.isAuthorized {
                participantsSection
            }
            if let photos = viewModel.event.photos,
               !photos.isEmpty {
                PhotoSectionView(
                    with: photos,
                    canDelete: isAuthor,
                    reportClbk: { viewModel.reportPhoto($0) },
                    deleteClbk: deletePhoto
                )
            }
            authorSection
            if !viewModel.event.comments.isEmpty {
                commentsSection
            }
            if defaults.isAuthorized {
                AddCommentButton(isCreatingComment: $isCreatingComment)
                    .sheet(isPresented: $isCreatingComment) {
                        TextEntryView(
                            mode: .newForEvent(id: viewModel.event.id),
                            refreshClbk: refreshAction
                        )
                    }
            }
        }
        .opacity(viewModel.isLoading ? 0.5 : 1)
        .overlay {
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : 0)
        }
        .animation(.easeInOut, value: viewModel.isLoading)
        .disabled(viewModel.isLoading)
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
            Button("Ok", action: closeAlert)
        }
        .onReceive(viewModel.$event, perform: onReceiveOfEventSetupTrainHere)
        .onChange(of: viewModel.event.trainHere, perform: onChangeOfTrainHere)
        .onChange(of: viewModel.isEventDeleted, perform: dismissDeleted)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: defaults.isAuthorized, perform: dismissNotAuth)
        .onDisappear(perform: cancelTasks)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isAuthor && network.isConnected {
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
    var mainInfo: some View {
        Group {
            Text(viewModel.event.formattedTitle)
                .font(.title2.bold())
            dateInfo
            addressInfo
        }
    }

    var dateInfo: some View {
        HStack {
            Text("Когда")
            Spacer()
            Text(viewModel.event.eventDateString)
                .fontWeight(.medium)
        }
    }

    var addressInfo: some View {
        HStack {
            Text("Где")
            Spacer()
            Text(viewModel.event.shortAddress)
                .fontWeight(.medium)
        }
    }

    var locationInfo: some View {
        SportsGroundLocationInfo(
            ground: $viewModel.event.sportsGround,
            address: viewModel.event.fullAddress ?? viewModel.event.shortAddress,
            appleMapsURL: viewModel.event.sportsGround.appleMapsURL
        )
    }

    var descriptionSection: some View {
        Section("Описание") {
            Text(.init(viewModel.event.formattedDescription))
                .tint(.blue)
                .textSelection(.enabled)
        }
    }

    var participantsSection: some View {
        Section("Участники") {
            if viewModel.hasParticipants {
                participantsButton
            }
            if viewModel.isEventCurrent {
                Toggle("Пойду на мероприятие", isOn: $trainHere)
                    .disabled(viewModel.isLoading || !network.isConnected)
                    .onChange(of: trainHere, perform: changeTrainHereStatus)
            }
        }
    }

    var participantsButton: some View {
        NavigationLink {
            UsersListView(mode: .eventParticipants(list: viewModel.event.participants))
        } label: {
            HStack {
                Text("Идут")
                Spacer()
                Text("peopleTrainHere \(viewModel.event.participants.count)")
                .foregroundColor(.secondary)
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
    func onChangeOfTrainHere(value: Bool) {
        trainHere = value
    }

    var authorSection: some View {
        Section("Организатор") {
            NavigationLink {
                UserDetailsView(for: viewModel.event.author)
            } label: {
                HStack(spacing: 16) {
                    CacheImageView(url: viewModel.event.author?.avatarURL)
                    Text(viewModel.event.authorName.valueOrEmpty)
                        .fontWeight(.medium)
                }
            }
            .disabled(
                !defaults.isAuthorized
                || viewModel.event.authorID == defaults.mainUserInfo?.userID
                || !network.isConnected
            )
        }
    }

    var commentsSection: some View {
        Comments(
            items: viewModel.event.comments,
            reportClbk: { viewModel.reportComment($0) },
            deleteClbk: { id in
                deleteCommentTask = Task {
                    await viewModel.delete(commentID: id, with: defaults)
                }
            },
            editClbk: setupCommentToEdit
        )
    }

    func setupCommentToEdit(_ comment: Comment) {
        editComment = comment
    }

    func askForInfo(refresh: Bool = false) async {
        await viewModel.askForEvent(refresh: refresh, with: defaults)
    }

    func refreshAction() {
        refreshButtonTask = Task { await askForInfo(refresh: true) }
    }

    var deleteButton: some View {
        Button(action: toggleDeleteConfirmation) {
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
            Image(systemName: "rectangle.and.pencil.and.ellipsis")
        }
    }

    func toggleDeleteConfirmation() {
        showDeleteDialog.toggle()
    }

    func deletePhoto(photo: Photo) {
        deletePhotoTask = Task {
            await viewModel.delete(photo, with: defaults)
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

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func dismissNotAuth(isAuth: Bool) {
        if !isAuth { dismiss() }
    }

    func dismissDeleted(isDeleted: Bool) {
        dismiss()
        onDeletion()
    }

    func cancelTasks() {
        [refreshButtonTask, deleteCommentTask, goingToEventTask, deletePhotoTask, deleteEventTask].forEach { $0?.cancel() }
    }
}

#if DEBUG
struct EventDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailsView(with: .preview, deleteClbk: {})
            .environmentObject(CheckNetworkService())
            .environmentObject(DefaultsService())
    }
}
#endif
