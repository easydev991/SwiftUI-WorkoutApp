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
            titleAddressSection()
            if viewModel.isPhotoGridShown {
                gridWithPhotosSection()
            }
            participantsAndEventSection()
            authorSection()
            commentsSection()
        }
        .navigationTitle("Площадка")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension SportsGroundView {
    func titleAddressSection() -> some View {
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
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
        }
    }

    func gridWithPhotosSection() -> some View {
        Section("Фотографии") {
            LazyVGrid(columns: viewModel.photoColumns.items) {
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

    func participantsAndEventSection() -> some View {
        Section {
            if viewModel.showParticipants {
                linkToParticipantsView()
            }
#warning("TODO: интеграция с сервером")
            Toggle("Тренируюсь здесь", isOn: $viewModel.isMySportsGround)
            createEventLink()
        }
    }

    func linkToParticipantsView() -> some View {
        NavigationLink {
            PersonsListView(model: viewModel.ground)
                .navigationTitle("Здесь тренируются")
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            HStack {
                Text("Здесь тренируются")
                Spacer()
                Text(
                    "people_train_here \(viewModel.ground.peopleTrainHereCount)",
                    tableName: "Plurals"
                )
                .foregroundColor(.secondary)
            }
        }
    }

    func createEventLink() -> some View {
        NavigationLink {
            CreateEventView(viewModel: .init(with: viewModel.ground))
        } label: {
            Text("Создать мероприятие")
                .fontWeight(.medium)
                .foregroundColor(.blue)
        }
    }

    func authorSection() -> some View {
        Section("Добавил") {
            HStack(spacing: 16) {
                AsyncImage(url: .init(string: viewModel.ground.author.imageStringURL)) { phase in
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

    func commentsSection() -> some View {
        Section("Комментарии") {
            VStack(alignment: .leading, spacing: 16) {
#warning("TODO: интеграция с сервером")
#warning("TODO: сверстать список комментариев")
                NavigationLink {
                    CreateCommentView()
                } label: {
                    Label {
                        Text("Добавить комментарий")
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
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
