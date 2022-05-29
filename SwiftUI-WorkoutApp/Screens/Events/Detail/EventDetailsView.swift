import SwiftUI

/// Экран с детальной информацией о мероприятии
struct EventDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel: EventDetailsViewModel
    @State private var needRefresh = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var isCreatingComment = false
    @State private var showDeleteDialog = false
    @State private var editComment: Comment?
    @State private var goingToEventTask: Task<Void, Never>?
    @State private var deleteCommentTask: Task<Void, Never>?
    @State private var deleteEventTask: Task<Void, Never>?
    @State private var refreshButtonTask: Task<Void, Never>?
    @Binding private var needRefreshOnDelete: Bool

    init(
        with event: EventResponse,
        refreshOnDelete: Binding<Bool>
    ) {
        _needRefreshOnDelete = refreshOnDelete
        _viewModel = StateObject(wrappedValue: .init(with: event))
    }

    var body: some View {
        ZStack {
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
                    PhotoSectionView(with: photos)
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
                                isSent: $needRefresh
                            )
                        }
                }
            }
            .opacity(viewModel.isLoading ? 0.5 : 1)
            .animation(.easeInOut, value: viewModel.isLoading)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
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
        .onChange(of: defaults.isAuthorized, perform: dismissNotAuth)
        .onDisappear(perform: cancelTasks)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isAuthor {
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
            Text(viewModel.event.formattedDescription)
        }
    }

    var participantsSection: some View {
        Section("Участники") {
            if let participants = viewModel.event.participantsOptional,
               !participants.isEmpty {
                linkToParticipants
            }
            if (viewModel.event.isCurrent).isTrue {
                isGoingToggle
            }
        }
    }

    var linkToParticipants: some View {
        NavigationLink {
            UsersListView(mode: .participants(list: viewModel.event.participants))
                .navigationTitle("Пойдут на мероприятие")
        } label: {
            HStack {
                Text("Идут")
                Spacer()
                Text(
                    "peopleTrainHere \(viewModel.event.participants.count)",
                    tableName: "Plurals"
                )
                .foregroundColor(.secondary)
            }
        }
    }

    var isGoingToggle: some View {
        CustomToggle(
            isOn: $viewModel.event.trainHere,
            title: "Пойду на мероприятие",
            action: changeIsGoingToEvent
        )
        .disabled(viewModel.isLoading)
    }

    var authorSection: some View {
        Section("Организатор") {
            NavigationLink {
                UserDetailsView(for: viewModel.event.author)
            } label: {
                HStack(spacing: 16) {
                    CacheImageView(url: viewModel.event.author?.avatarURL)
                    Text(viewModel.event.name.valueOrEmpty)
                        .fontWeight(.medium)
                }
            }
            .disabled(!defaults.isAuthorized || viewModel.event.authorID == defaults.mainUserID)
        }
    }

    var commentsSection: some View {
        Comments(
            items: viewModel.event.comments,
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
        await viewModel.askForEvent(with: defaults, refresh: refresh)
    }

    func changeIsGoingToEvent() {
        goingToEventTask = Task {
            await viewModel.changeIsGoingToEvent(with: defaults)
        }
    }

    func refreshAction(refresh: Bool) {
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
            Button(role: .destructive) {
                deleteEventTask = Task {
                    await viewModel.deleteEvent(with: defaults)
                }
            } label: {
                Text("Удалить")
            }
        }
    }

    var editEventButton: some View {
        NavigationLink {
            EventFormView(
                for: .editExisting(viewModel.event),
                needRefresh: $needRefresh
            )
        } label: {
            Image(systemName: "rectangle.and.pencil.and.ellipsis")
        }
    }

    func toggleDeleteConfirmation() {
        showDeleteDialog.toggle()
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    var isAuthor: Bool {
        viewModel.event.authorID == defaults.mainUserID
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func dismissNotAuth(isAuth: Bool) {
        if !isAuth { dismiss() }
    }

    func dismissDeleted(isDeleted: Bool) {
        dismiss()
        needRefreshOnDelete.toggle()
    }

    func cancelTasks() {
        [refreshButtonTask, deleteCommentTask, goingToEventTask, deleteEventTask].forEach { $0?.cancel() }
    }
}

struct EventDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailsView(with: .mock, refreshOnDelete: .constant(false))
            .environmentObject(DefaultsService())
    }
}
