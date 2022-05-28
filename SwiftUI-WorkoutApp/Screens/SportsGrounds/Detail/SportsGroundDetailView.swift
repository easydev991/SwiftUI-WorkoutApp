import SwiftUI

/// Экран с детальной информацией о площадке
struct SportsGroundDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel: SportsGroundDetailViewModel
    @State private var needRefresh = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var isCreatingComment = false
    @State private var showDeleteDialog = false
    @State private var editComment: Comment?
    @State private var changeTrainHereTask: Task<Void, Never>?
    @State private var deleteCommentTask: Task<Void, Never>?
    @State private var deleteGroundTask: Task<Void, Never>?
    @State private var refreshButtonTask: Task<Void, Never>?
    @Binding private var needRefreshOnDelete: Bool

    init(for ground: SportsGround, refreshOnDelete: Binding<Bool> = .constant(false)) {
        _needRefreshOnDelete = refreshOnDelete
        _viewModel = StateObject(wrappedValue: .init(with: ground))
    }

    var body: some View {
        ZStack {
            Form {
                titleSubtitleSection
                locationInfo
                if let photos = viewModel.ground.photos,
                   !photos.isEmpty {
                    PhotosCollection(items: photos)
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
                            TextEntryView(mode: .newForGround(id: viewModel.ground.id), isSent: $needRefresh)
                        }
                }
            }
            .opacity(viewModel.isLoading ? 0.5 : 1)
            .animation(.default, value: viewModel.isLoading)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
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
                isSent: $needRefresh
            )
        }
        .task { await askForInfo() }
        .refreshable { await askForInfo(refresh: true) }
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .onChange(of: viewModel.isDeleted, perform: dismissDeleted)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: needRefresh, perform: refreshAction)
        .onDisappear(perform: cancelTasks)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isGroundAuthor {
                    Group {
                        deleteButton
                        editGroundButton
                    }
                    .disabled(viewModel.isLoading)
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
            CustomToggle(
                isOn: $viewModel.ground.trainHere,
                title: "Тренируюсь здесь",
                action: changeTrainHereStatus
            )
            .disabled(viewModel.isLoading)
            createEventLink
        }
    }

    func changeTrainHereStatus() {
        changeTrainHereTask = Task {
            await viewModel.changeTrainHereStatus(with: defaults)
        }
    }

    var linkToParticipantsView: some View {
        NavigationLink {
            UsersListView(mode: .participants(list: viewModel.ground.participants))
                .navigationTitle("Здесь тренируются")
        } label: {
            HStack {
                Text("Здесь тренируются")
                Spacer()
                Text(
                    "peopleTrainHere \(viewModel.ground.participants.count)",
                    tableName: "Plurals"
                )
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
    }

    var authorSection: some View {
        Section("Добавил") {
            NavigationLink(destination: UserDetailsView(userID: viewModel.ground.authorID)) {
                HStack(spacing: 16) {
                    CacheImageView(url: viewModel.ground.author?.avatarURL)
                    Text(viewModel.ground.authorName)
                        .fontWeight(.medium)
                }
            }
            .disabled(!defaults.isAuthorized || viewModel.ground.authorID == defaults.mainUserID)
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
            Button(role: .destructive) {
                deleteGroundTask = Task {
                    await viewModel.deleteGround(with: defaults)
                }
            } label: {
                Text("Удалить")
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
                needRefreshOnSave: $needRefresh
            )
        } label: {
            Image(systemName: "rectangle.and.pencil.and.ellipsis")
        }
    }

    func refreshAction(refresh: Bool) {
        refreshButtonTask = Task { await askForInfo(refresh: true) }
    }

    func askForInfo(refresh: Bool = false) async {
        await viewModel.askForSportsGround(refresh: refresh)
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    var isGroundAuthor: Bool {
        viewModel.ground.authorID == defaults.mainUserID
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func dismissDeleted(isDeleted: Bool) {
        dismiss()
        needRefreshOnDelete.toggle()
    }

    func cancelTasks() {
        [refreshButtonTask, deleteCommentTask,
         changeTrainHereTask, deleteGroundTask].forEach { $0?.cancel() }
    }
}

struct SportsGroundView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SportsGroundDetailView(for: .mock, refreshOnDelete: .constant(false))
                .environmentObject(DefaultsService())
        }
    }
}
