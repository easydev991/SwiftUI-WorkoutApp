import SwiftUI

/// Экран с детальной информацией о мероприятии
struct EventDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel: EventDetailsViewModel
    @State private var needUpdate = false
    @State private var isCreatingComment = false
    @State private var editComment: Comment?
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var showDeleteDialog = false
    @State private var goingToEventTask: Task<Void, Never>?
    @State private var deleteCommentTask: Task<Void, Never>?
    @State private var deleteEventTask: Task<Void, Never>?
    @State private var refreshButtonTask: Task<Void, Never>?
    @Binding private var needRefreshOnDelete: Bool

    init(
        with event: EventResponse,
        refreshOnDelete: Binding<Bool>
    ) {
        _viewModel = StateObject(wrappedValue: .init(with: event))
        _needRefreshOnDelete = refreshOnDelete
    }

    var body: some View {
        ZStack {
            Form {
                mainInfo
                locationInfo
                if viewModel.event.hasDescription {
                    descriptionSection
                }
                participantsSection
                if let photos = viewModel.event.photos,
                   !photos.isEmpty {
                    PhotosCollection(items: photos)
                }
                authorSection
                if !viewModel.event.comments.isEmpty {
                    commentsSection
                }
                if defaults.isAuthorized {
                    AddCommentButton(isCreatingComment: $isCreatingComment)
                }
            }
            .opacity(viewModel.event.id == .zero ? .zero : 1)
            .disabled(viewModel.isLoading)
            .animation(.default, value: viewModel.isLoading)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .task { await askForInfo() }
        .refreshable { await askForInfo(refresh: true) }
        .alert(alertMessage, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: defaults.isAuthorized, perform: dismissNotAuth)
        .onChange(of: viewModel.isDeleted, perform: dismissDeleted)
        .onChange(of: needUpdate, perform: refreshAction)
        .sheet(isPresented: $isCreatingComment) {
            CommentView(
                mode: .newForEvent(id: viewModel.event.id),
                isSent: $needUpdate
            )
        }
        .sheet(item: $editComment) {
            CommentView(
                mode: .editEvent(
                    .init(
                        objectID: viewModel.event.id,
                        commentID: $0.id,
                        oldComment: $0.formattedBody
                    )
                ),
                isSent: $needUpdate
            )
        }
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
            if defaults.isAuthorized && (viewModel.event.isCurrent).isTrue {
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
        CustomToggle(isOn: $viewModel.isGoing, title: "Пойду на мероприятие") {
            changeIsGoingToEvent(newStatus: !viewModel.isGoing)
        }
        .disabled(viewModel.isLoading)
    }

    var authorSection: some View {
        Section("Организатор") {
            NavigationLink {
                UserDetailsView(userID: viewModel.event.authorID)
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
            editClbk: { comment in
                editComment = comment
            }
        )
    }

    func askForInfo(refresh: Bool = false) async {
        await viewModel.askForEvent(with: defaults, refresh: refresh)
    }

    func changeIsGoingToEvent(newStatus: Bool) {
        goingToEventTask = Task {
            await viewModel.changeIsGoingToEvent(
                isGoing: newStatus, with: defaults
            )
        }
    }

    func refreshAction(refresh: Bool = false) {
        refreshButtonTask = Task { await askForInfo(refresh: refresh) }
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
                    await viewModel.deleteEvent(viewModel.event.id, with: defaults)
                }
            } label: {
                Text("Удалить")
            }
        }
    }

    var editEventButton: some View {
        NavigationLink {
            CreateOrEditEventView(
                for: .editExisting(viewModel.event),
                needRefresh: $needUpdate
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
        [goingToEventTask, deleteCommentTask, refreshButtonTask, deleteEventTask].forEach { $0?.cancel() }
    }
}

struct EventDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailsView(with: .mock, refreshOnDelete: .constant(false))
            .environmentObject(DefaultsService())
    }
}
