import SwiftUI

/// Экран с детальной информацией о площадке
struct SportsGroundView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = SportsGroundViewModel()
    @State private var needUpdateComments = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var isCreatingComment = false
    @State private var editComment: Comment?
    @State private var changeTrainHereTask: Task<Void, Never>?
    @State private var deleteCommentTask: Task<Void, Never>?
    @State private var refreshButtonTask: Task<Void, Never>?

    let mode: Mode

    var body: some View {
        ZStack {
            Form {
                titleSubtitleSection
                mapInfo
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
                }
            }
            .opacity(viewModel.ground.id == .zero ? .zero : 1)
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
        .onChange(of: needUpdateComments, perform: refreshAction)
        .sheet(isPresented: $isCreatingComment) {
            CommentView(mode: .newForGround(id: viewModel.ground.id), isSent: $needUpdateComments)
        }
        .sheet(item: $editComment) {
            CommentView(
                mode: .editGround(
                    .init(
                        mainID: viewModel.ground.id,
                        commentID: $0.id,
                        oldComment: $0.formattedBody
                    )
                ),
                isSent: $needUpdateComments
            )
        }
        .onDisappear(perform: cancelTasks)
        .toolbar { refreshButton }
        .navigationTitle("Площадка")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension SportsGroundView {
    enum Mode {
        case full(SportsGround)
        case limited(id: Int)
    }
}
private extension SportsGroundView {
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

    var mapInfo: some View {
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
            CustomToggle(isOn: $viewModel.ground.trainHere, title: "Тренируюсь здесь") {
                changeTrainHereStatus(newStatus: !viewModel.ground.trainHere)
            }
            .disabled(viewModel.isLoading)
            createEventLink
        }
    }

    func changeTrainHereStatus(newStatus: Bool) {
        changeTrainHereTask = Task {
            await viewModel.changeTrainHereStatus(
                groundID: viewModel.ground.id,
                trainHere: newStatus,
                with: defaults
            )
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
            CreateOrEditEventView(
                for: .createForSelected(viewModel.ground),
                userInfo: defaults.mainUserInfo ?? .emptyValue
            )
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
            .disabled(!defaults.isAuthorized)
        }
    }

    var commentsSection: some View {
        Comments(
            items: viewModel.ground.comments,
            deleteClbk: { id in
                deleteCommentTask = Task {
                    await viewModel.delete(
                        groundID: viewModel.ground.id,
                        commentID: id,
                        with: defaults
                    )
                }
            },
            editClbk: { comment in
                editComment = comment
            }
        )
    }

    var refreshButton: some View {
        Button {
            refreshButtonTask = Task { await askForInfo() }
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
        }
        .opacity(viewModel.showRefreshButton ? 1 : .zero)
    }

    func refreshAction(refresh: Bool = false) {
        refreshButtonTask = Task { await askForInfo(refresh: true) }
    }

    func askForInfo(refresh: Bool = false) async {
        switch mode {
        case let .full(ground):
            await viewModel.makeSportsGroundInfo(
                groundID: ground.id,
                with: defaults,
                refresh: refresh
            )
        case let .limited(id):
            await viewModel.makeSportsGroundInfo(
                groundID: id,
                with: defaults,
                refresh: refresh
            )
        }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func cancelTasks() {
        [refreshButtonTask, deleteCommentTask, changeTrainHereTask].forEach { $0?.cancel() }
    }
}

struct SportsGroundView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SportsGroundView(mode: .full(.mock))
                .environmentObject(DefaultsService())
                .previewDevice("iPhone SE (3rd generation)")
        }
    }
}
