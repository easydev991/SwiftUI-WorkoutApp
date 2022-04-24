//
//  SportsGroundView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 22.04.2022.
//

import SwiftUI

struct SportsGroundView: View {
    let model: SportsGround

    @State private var isMySportsGround = false
    @State private var showParticipants = false
    @State private var columnsCount = Columns.one
    private var columns: [GridItem] {
        .init(
            repeating: .init(.flexible()),
            count: columnsCount.rawValue
        )
    }

    var body: some View {
        Form {
            titlePhotoAddressSection()
            participantsAndEventSection()
            authorSection()
            commentsSection()
        }
        .navigationTitle("Площадка")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            columnsCount = .init(model.photos.count)
            isMySportsGround = model.mine
            showParticipants = model.peopleTrainHereCount > .zero
        }
    }
}

private extension SportsGroundView {
    enum Columns: Int {
        case one = 1, two, three
        init(_ photosCount: Int) {
            switch photosCount {
            case 1: self = .one
            case 2: self = .two
            default: self = .three
            }
        }
    }

    func titlePhotoAddressSection() -> some View {
        Section {
            HStack {
                Text(model.shortTitle)
                    .font(.title2.bold())
                Spacer()
                Text(model.subtitle ?? "")
                    .foregroundColor(.secondary)
            }
            Text(model.address)
            gridWithPhotos()
        }
    }

    func gridWithPhotos() -> some View {
        LazyVGrid(columns: columns) {
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

    func participantsAndEventSection() -> some View {
        Section {
            if showParticipants {
                NavigationLink {
    #warning("Сделать экран со списком тренирующихся")
                    Text("Экран со списком тренирующихся")
                        .navigationTitle("Здесь тренируются")
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
#warning("Сохранять изменения в базе данных")
            Toggle("Тренируюсь здесь", isOn: $isMySportsGround)
            createEventButton()
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
                            .scaledToFill()
                            .frame(width: 36, height: 36)
                            .cornerRadius(8)
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

    func createEventButton() -> some View {
        NavigationLink {
#warning("Сделать экран для создания мероприятия")
            Text("Экран для создания мероприятия")
                .navigationTitle("Мероприятие")
        } label: {
            Text("Создать мероприятие")
                .fontWeight(.medium)
        }
    }

    func commentsSection() -> some View {
        Section("Комментарии") {
            VStack(alignment: .leading, spacing: 16) {
#warning("Скачать с бэка и отобразить список комментариев")
                NavigationLink {
                    CreateCommentView()
                } label: {
                    Label("Добавить комментарий", systemImage: "plus.message.fill")
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
