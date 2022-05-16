//
//  SportsGroundView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 22.04.2022.
//

import SwiftUI

struct SportsGroundView: View {
    @EnvironmentObject private var defaults: UserDefaultsService
    @ObservedObject var viewModel: SportsGroundViewModel
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var isCreatingComment = false
    @State private var editComment: Comment?
    @State private var deleteCommentTask: Task<Void, Never>?
    @State private var refreshButtonTask: Task<Void, Never>?

    init(model: SportsGroundViewModel) {
        viewModel = model
    }

    var body: some View {
        ZStack {
            Form {
                titleAddressSection
                if viewModel.isPhotoGridShown {
                    gridWithPhotosSection
                }
                if defaults.isAuthorized {
                    participantsAndEventSection
                }
                authorSection
                if !viewModel.ground.comments.isEmpty {
                    commentsSection
                }
                if defaults.isAuthorized {
                    addNewCommentButton
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
        .sheet(item: $editComment) {
            CreateOrEditCommentView(
                mode: .edit(
                    groundID: viewModel.groundID,
                    commentID: $0.id,
                    commentText: $0.formattedBody
                )
            )
        }
        .sheet(isPresented: $isCreatingComment) {
            CreateOrEditCommentView(mode: .create(groundID: viewModel.groundID))
        }
        .onDisappear(perform: cancelTasks)
        .toolbar { refreshButton }
        .navigationTitle("Площадка")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension SportsGroundView {
    var titleAddressSection: some View {
        Section {
            HStack {
                Text(viewModel.ground.shortTitle)
                    .font(.title2.bold())
                Spacer()
                Text(viewModel.ground.subtitle.valueOrEmpty)
                    .foregroundColor(.secondary)
            }
            MapSnapshotView(model: $viewModel.ground)
                .frame(height: 150)
                .cornerRadius(8)
            Text(viewModel.ground.address.valueOrEmpty)
            Button {
                if let url = viewModel.ground.appleMapsURL,
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Построить маршрут")
                    .blueMediumWeight()
            }
        }
    }

    var gridWithPhotosSection: some View {
        Section("Фотографии") {
            LazyVGrid(
                columns: .init(
                    repeating: .init(.flexible(maximum: 150)),
                    count: viewModel.photoColumns.rawValue
                )
            ) {
                ForEach(viewModel.ground.photos) {
                    CacheAsyncImage(url: $0.imageURL) { phase in
                        switch phase {
                        case let .success(image):
                            image
                                .resizable()
                                .scaledToFill()
                                .cornerRadius(8)
                        case let .failure(error):
                            EmptyGrayRoundedRect(size: .init(width: 100, height: 100))
                                .overlay {
                                    Text(error.localizedDescription)
                                        .multilineTextAlignment(.center)
                                }
                        default:
                            ProgressView()
                        }
                    }
                }
            }
        }
    }

    var participantsAndEventSection: some View {
        Section {
            if viewModel.showParticipants {
                linkToParticipantsView
            }
            Toggle("Тренируюсь здесь", isOn: $viewModel.ground.trainHere)
                .disabled(viewModel.isLoading)
                .onChange(of: viewModel.ground.trainHere, perform: changeTrainHereStatus)
            createEventLink
        }
    }

    func changeTrainHereStatus(newStatus: Bool) {
        Task { await viewModel.changeTrainHereStatus(with: defaults) }
    }

    var linkToParticipantsView: some View {
        NavigationLink {
            UsersListView(mode: .sportsGroundVisitors(list: viewModel.ground.participants))
                .navigationTitle("Здесь тренируются")
        } label: {
            HStack {
                Text("Здесь тренируются")
                Spacer()
                Text(
                    "peopleTrainHere \(viewModel.ground.usersTrainHereCount.valueOrZero)",
                    tableName: "Plurals"
                )
                .foregroundColor(.secondary)
            }
        }
    }

    var createEventLink: some View {
        NavigationLink {
            CreateEventView(viewModel: .init(mode: .selectedSportsGround(viewModel.ground)))
        } label: {
            Text("Создать мероприятие").blueMediumWeight()
        }
    }

    var authorSection: some View {
        Section("Добавил") {
            NavigationLink(destination: UserProfileView(userID: viewModel.ground.author.userID.valueOrZero)) {
                HStack(spacing: 16) {
                    CacheImageView(url: viewModel.ground.author.avatarURL)
                    Text(viewModel.ground.author.userName.valueOrEmpty)
                        .fontWeight(.medium)
                }
            }
            .disabled(!defaults.isAuthorized)
        }
    }

    var commentsSection: some View {
        Section("Комментарии") {
            List(viewModel.ground.comments) { comment in
                SportsGroundCommentView(model: comment) { id in
                    deleteCommentTask = Task { await viewModel.delete(commentID: id, with: defaults) }
                } editClbk: { id, text in
                    editComment = .init(id: id, body: text, date: comment.date, user: comment.user)
                }
            }
        }
    }

    var addNewCommentButton: some View {
        Button {
            isCreatingComment.toggle()
        } label: {
            Label("Добавить комментарий", systemImage: "plus.message.fill")
                .foregroundColor(.blue)
        }
    }

    var refreshButton: some View {
        Button {
            refreshButtonTask = Task { await askForInfo() }
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
        }
        .opacity(viewModel.showRefreshButton ? 1 : .zero)
    }

    func askForInfo(refresh: Bool = false) async {
        await viewModel.makeSportsGroundInfo(with: defaults, refresh: refresh)
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        alertMessage = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func cancelTasks() {
        [refreshButtonTask, deleteCommentTask].forEach { $0?.cancel() }
    }
}

struct SportsGroundView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SportsGroundView(model: .init(groundID: .zero))
                .environmentObject(UserDefaultsService())
                .previewDevice("iPhone SE (3rd generation)")
        }
    }
}
