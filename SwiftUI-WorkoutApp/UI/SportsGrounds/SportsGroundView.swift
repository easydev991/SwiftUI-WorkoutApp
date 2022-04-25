//
//  SportsGroundView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 22.04.2022.
//

import SwiftUI

struct SportsGroundView: View {
    let model: SportsGround

    @State private var isPhotoGridShown = false
    @State private var photoColumns = Columns.one
    @State private var isMySportsGround = false
    @State private var showParticipants = false

    var body: some View {
        Form {
            titleAddressSection()
            if isPhotoGridShown {
                gridWithPhotosSection()
            }
            participantsAndEventSection()
            authorSection()
            commentsSection()
        }
        .navigationTitle("Площадка")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isPhotoGridShown = !model.photos.isEmpty
            photoColumns = .init(model.photos.count)
            isMySportsGround = model.mine
            showParticipants = model.peopleTrainHereCount > .zero
        }
    }
}

private extension SportsGroundView {
    enum Columns: Int {
        case one = 1, two, three
        var items: [GridItem] {
            .init(repeating: .init(.flexible()), count: rawValue)
        }
        init(_ photosCount: Int) {
            switch photosCount {
            case 1: self = .one
            case 2: self = .two
            default: self = .three
            }
        }
    }

    func titleAddressSection() -> some View {
        Section {
            HStack {
                Text(model.shortTitle)
                    .font(.title2.bold())
                Spacer()
                Text(model.subtitle ?? "")
                    .foregroundColor(.secondary)
            }
            MapSnapshotView(model: model)
                .frame(height: 150)
                .cornerRadius(8)
            Text(model.address)
            Button {
                if let url = model.appleMapsURL,
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
            LazyVGrid(columns: photoColumns.items) {
                ForEach(model.photos) {
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
            if showParticipants {
                linkToParticipantsView()
            }
#warning("TODO: интеграция с сервером")
            Toggle("Тренируюсь здесь", isOn: $isMySportsGround)
            createEventLink(model)
        }
    }

    func linkToParticipantsView() -> some View {
        NavigationLink {
            PersonsListView(model: model)
                .navigationTitle("Здесь тренируются")
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            HStack {
                Text("Здесь тренируются")
                Spacer()
                Text(
                    "people_train_here \(model.peopleTrainHereCount)",
                    tableName: "Plurals"
                )
                .foregroundColor(.secondary)
            }
        }
    }

    func createEventLink(_ model: SportsGround) -> some View {
        NavigationLink {
            CreateEventView(model: model)
        } label: {
            Text("Создать мероприятие")
                .fontWeight(.medium)
                .foregroundColor(.blue)
        }
    }

    func authorSection() -> some View {
        Section("Добавил") {
            HStack(spacing: 16) {
                AsyncImage(url: .init(string: model.author.imageStringURL)) { phase in
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
                Text(model.author.name)
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
            SportsGroundView(model: .mock)
                .previewDevice("iPhone SE (3rd generation)")
        }
    }
}
