//
//  SportsGroundView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 22.04.2022.
//

import SwiftUI

struct SportsGroundView: View {
    @ObservedObject var viewModel: SportsGroundViewModel

    init(model: SportsGroundViewModel) {
        viewModel = model
    }

    var body: some View {
        Form {
            titleAddressSection
            if viewModel.isPhotoGridShown {
                gridWithPhotosSection
            }
            participantsAndEventSection
            authorSection
            commentsSection
        }
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
                Text(viewModel.ground.subtitle ?? "")
                    .foregroundColor(.secondary)
            }
            MapSnapshotView(model: viewModel.ground)
                .frame(height: 150)
                .cornerRadius(8)
            Text(viewModel.ground.address)
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
                    AsyncImage(url: .init(string: $0.stringURL)) { phase in
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
            PersonsListView(model: viewModel.ground)
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
        ) {
            Text("Создать мероприятие")
                .blueMediumWeight()
        }
    }

    var authorSection: some View {
        Section("Добавил") {
            HStack(spacing: 16) {
                AsyncImage(url: .init(string: viewModel.authorImageStringURL)) { phase in
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
                Text(viewModel.ground.author.name)
                    .fontWeight(.medium)
            }
        }
    }

    var commentsSection: some View {
        Section("Комментарии") {
            VStack(alignment: .leading, spacing: 16) {
#warning("TODO: интеграция с сервером")
#warning("TODO: сверстать список комментариев")
                NavigationLink(destination: CreateCommentView()) {
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
    }
}

struct SportsGroundView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SportsGroundView(model: .init(with: .mock))
                .previewDevice("iPhone SE (3rd generation)")
        }
    }
}
