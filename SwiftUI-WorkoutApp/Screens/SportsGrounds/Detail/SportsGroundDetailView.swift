import SwiftUI

/// Экран с детальной информацией о площадке
struct SportsGroundDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var network: CheckNetworkService
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel: SportsGroundDetailViewModel
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var isCreatingComment = false
    @State private var showDeleteDialog = false
    @State private var trainHere = false
    @State private var editComment: Comment?
    @State private var changeTrainHereTask: Task<Void, Never>?
    @State private var deleteCommentTask: Task<Void, Never>?
    @State private var deleteGroundTask: Task<Void, Never>?
    @State private var deletePhotoTask: Task<Void, Never>?
    @State private var refreshButtonTask: Task<Void, Never>?
    private let onDeletionClbk: (Int) -> Void

    init(
        for ground: SportsGround,
        onDeletion: @escaping (Int) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: .init(with: ground))
        onDeletionClbk = onDeletion
    }

    var body: some View {
        Form {
            titleSubtitleSection
            locationInfo
            if let photos = viewModel.ground.photos,
               !photos.isEmpty {
                PhotoSectionView(
                    with: photos,
                    canDelete: isGroundAuthor,
                    deleteClbk: deletePhoto
                )
            }
            if defaults.isAuthorized {
                participantsAndEventSection
            }
            authorSection
            if !viewModel.ground.comments.isEmpty {
                commentsSection
            }
            if defaults.isAuthorized {
                AddCommentButton(isCreatingComment: $isCreatingComment)
                    .sheet(isPresented: $isCreatingComment) {
                        TextEntryView(
                            mode: .newForGround(id: viewModel.ground.id),
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
        .animation(.default, value: viewModel.isLoading)
        .disabled(viewModel.isLoading)
        .sheet(item: $editComment) {
            TextEntryView(
                mode: .editGround(
                    .init(
                        parentObjectID: viewModel.ground.id,
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
        .onReceive(viewModel.$ground, perform: onReceiveOfGroundSetupTrainHere)
        .onChange(of: viewModel.ground.trainHere, perform: onChangeOfTrainHere)
        .onChange(of: viewModel.isDeleted, perform: dismissDeleted)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: defaults.isAuthorized, perform: dismissNotAuth)
        .onDisappear(perform: cancelTasks)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isGroundAuthor {
                    Group {
                        deleteButton
                        editGroundButton
                    }
                    .disabled(viewModel.isLoading || !network.isConnected)
                }
            }
        }
        .navigationTitle("Площадка")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension SportsGroundDetailView {
    var titleSubtitleSection: some View {
        Section {
            HStack {
                Text(viewModel.ground.shortTitle)
                    .font(.title2.bold())
                Spacer()
                Text(viewModel.ground.subtitle.valueOrEmpty)
                    .foregroundColor(.secondary)
            }
        }
    }

    var locationInfo: some View {
        SportsGroundLocationInfo(
            ground: $viewModel.ground,
            address: viewModel.ground.address.valueOrEmpty,
            appleMapsURL: viewModel.ground.appleMapsURL
        )
    }

    var participantsAndEventSection: some View {
        Section {
            if let participants = viewModel.ground.usersTrainHere,
               !participants.isEmpty {
                linkToParticipantsView
            }
            Toggle("Тренируюсь здесь", isOn: $trainHere)
                .disabled(viewModel.isLoading || !network.isConnected)
                .onChange(of: trainHere, perform: changeTrainHereStatus)
            createEventLink
        }
    }

    func changeTrainHereStatus(newValue: Bool) {
        let oldValue = viewModel.ground.trainHere
        switch (oldValue, newValue) {
        case (true, true), (false, false):
            break // Пользователь не трогал тоггл
        case (true, false), (false, true):
            changeTrainHereTask = Task {
                await viewModel.changeTrainHereStatus(newValue, with: defaults)
            }
        }
    }

    /// Настраиваем начальное состояние `trainHere` при появлении экрана
    func onReceiveOfGroundSetupTrainHere(ground: SportsGround) {
        trainHere = ground.trainHere
    }

    /// Обновляем состояние `trainHere` при получении изменений от `viewModel`
    ///
    /// Например, если сервер вернул ошибку при попытке сменить статус
    func onChangeOfTrainHere(value: Bool) {
        trainHere = value
    }

    var linkToParticipantsView: some View {
        NavigationLink {
            UsersListView(mode: .groundParticipants(list: viewModel.ground.participants))
        } label: {
            HStack {
                Text("Здесь тренируются")
                Spacer()
                Text("peopleTrainHere \(viewModel.ground.participants.count)")
                .foregroundColor(.secondary)
            }
        }
    }

    var createEventLink: some View {
        NavigationLink {
            EventFormView(for: .createForSelected(viewModel.ground))
        } label: {
            Text("Создать мероприятие").blueMediumWeight()
        }
        .disabled(!network.isConnected)
    }

    var authorSection: some View {
        Section("Добавил") {
            NavigationLink(destination: UserDetailsView(for: viewModel.ground.author)) {
                HStack(spacing: 16) {
                    CacheImageView(url: viewModel.ground.author?.avatarURL)
                    Text(viewModel.ground.authorName)
                        .fontWeight(.medium)
                }
            }
            .disabled(
                !defaults.isAuthorized
                || viewModel.ground.authorID == defaults.mainUserInfo?.userID
                || !network.isConnected
            )
        }
    }

    var commentsSection: some View {
        Comments(
            items: viewModel.ground.comments,
            deleteClbk: { id in
                deleteCommentTask = Task {
                    await viewModel.delete(
                        commentID: id,
                        with: defaults
                    )
                }
            },
            editClbk: setupCommentToEdit
        )
    }

    func setupCommentToEdit(_ comment: Comment) {
        editComment = comment
    }

    var deleteButton: some View {
        Button(action: toggleDeleteConfirmation) {
            Image(systemName: "trash")
        }
        .confirmationDialog(
            Constants.Alert.deleteGround,
            isPresented: $showDeleteDialog,
            titleVisibility: .visible
        ) {
            Button("Удалить", role: .destructive) {
                deleteGroundTask = Task {
                    await viewModel.deleteGround(with: defaults)
                }
            }
        }
    }

    func toggleDeleteConfirmation() {
        showDeleteDialog.toggle()
    }

    var editGroundButton: some View {
        NavigationLink {
            SportsGroundFormView(
                .editExisting(viewModel.ground),
                refreshClbk: refreshAction
            )
        } label: {
            Image(systemName: "rectangle.and.pencil.and.ellipsis")
        }
    }

    func refreshAction() {
        refreshButtonTask = Task { await askForInfo(refresh: true) }
    }

    func askForInfo(refresh: Bool = false) async {
        await viewModel.askForSportsGround(refresh: refresh, with: defaults)
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

    var isGroundAuthor: Bool {
        defaults.isAuthorized
        ? viewModel.ground.authorID == defaults.mainUserInfo?.userID
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
        onDeletionClbk(viewModel.ground.id)
        defaults.setUserNeedUpdate(true)
    }

    func cancelTasks() {
        [refreshButtonTask, deleteCommentTask, changeTrainHereTask, deletePhotoTask, deleteGroundTask].forEach { $0?.cancel() }
    }
}

struct SportsGroundView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SportsGroundDetailView(for: .preview, onDeletion: { _ in })
                .environmentObject(CheckNetworkService())
                .environmentObject(DefaultsService())
        }
    }
}
