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
    @State private var deleteCommentTask: Task<Void, Never>?

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
                participantsAndEventSection
                authorSection
                if viewModel.showComments {
                    commentsSection
                }
                addNewCommentLink
            }
            .disabled(viewModel.isLoading)
            .animation(.default, value: viewModel.isLoading)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .task { await askForInfo() }
        .refreshable { await askForInfo(refresh: true) }
        .alert(Constants.Alert.error, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        } message: { Text(alertMessage) }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onDisappear(perform: cancelDeleteCommentTask)
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
                    repeating: .init(.flexible()),
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
                            Color.secondary
                                .frame(width: .infinity, height: 100)
                                .cornerRadius(8)
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
#warning("TODO: интеграция с сервером")
            Toggle("Тренируюсь здесь", isOn: $viewModel.isMySportsGround)
            createEventLink
        }
    }

    var linkToParticipantsView: some View {
        NavigationLink {
            UsersListView(mode: .sportsGroundVisitors(groundID: viewModel.groundID))
                .navigationTitle("Здесь тренируются")
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            HStack {
                Text("Здесь тренируются")
                Spacer()
                Text(
                    "peopleTrainHere \(viewModel.ground.peopleTrainHereCount)",
                    tableName: "Plurals"
                )
                .foregroundColor(.secondary)
            }
        }
    }

    var createEventLink: some View {
        NavigationLink(
            destination: CreateEventView(viewModel: .init(mode: .selectedSportsGround(viewModel.ground)))
        ) { Text("Создать мероприятие").blueMediumWeight() }
    }

    var authorSection: some View {
        Section("Добавил") {
            HStack(spacing: 16) {
                CacheAsyncImage(url: viewModel.ground.author.avatarURL) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .smallProfileImageRect()
                    case .failure:
                        Image(systemName: "person.fill")
                    default:
                        ProgressView()
                    }
                }
                Text(viewModel.ground.author.userName.valueOrEmpty)
                    .fontWeight(.medium)
            }
        }
    }

    var commentsSection: some View {
        Section("Комментарии") {
            List(viewModel.comments) {
                SportsGroundCommentView(model: $0) { id in
                    deleteCommentTask = Task { await viewModel.delete(commentID: id, with: defaults) }
                } editClbk: { id, text in
                    print("--- открываем экран CreateCommentView для комментария \(id) с текстом \(text)")
                }
            }
        }
    }

    var addNewCommentLink: some View {
        Section {
            NavigationLink(destination: CreateCommentView(groundID: viewModel.groundID)) {
                Label {
                    Text("Добавить комментарий")
                        .blueMediumWeight()
                } icon: {
                    Image(systemName: "plus.message.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
        }
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

    func cancelDeleteCommentTask() {
        deleteCommentTask?.cancel()
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
