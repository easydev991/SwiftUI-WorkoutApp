#if DEBUG
import Foundation

extension Photo {
    static var preview: Photo {
        .init(id: 1, stringURL: "avatar_default")
    }
}

extension CommentResponse {
    static var preview: CommentResponse {
        .init(
            id: 2569,
            body: "+ В центре парка, чистый воздух\r\n+ Кольца\r\n+ Тренажёры\r\n\r\n- Относительно далеко от метро",
            date: "2011-03-07T15:55:15+00:00",
            user: .preview
        )
    }
}

extension SportsGround {
    static var preview: SportsGround {
        .init(
            id: 3,
            typeID: 6,
            sizeID: 2,
            address: "м. Партизанская, улица 2-я Советская",
            author: .preview,
            cityID: 1,
            commentsCount: 1,
            countryID: 17,
            createDate: "2011-03-07T22:55:15+03:00",
            modifyDate: "2023-01-21T15:24:25+03:00",
            latitude: "55.795396",
            longitude: "37.762597",
            name: "№3 Средняя Легендарная",
            photos: [.preview],
            preview: "https://workout.su/uploads/userfiles/измайлово.jpg",
            usersTrainHereCount: nil,
            commentsOptional: [.preview],
            usersTrainHere: [.preview, .preview],
            trainHere: false
        )
    }
}

extension UserResponse {
    static var preview: UserResponse {
        .init(
            userName: "Kahar",
            fullName: "",
            email: "test@mail.ru",
            imageStringURL: "https://workout.su/uploads/avatars/2019/10/2019-10-07-01-10-08-yow.jpg",
            birthDateIsoString: "1990-11-25",
            createdIsoDateTimeSec: nil,
            userID: 24798,
            cityID: 1,
            countryID: 17,
            genderCode: 1,
            friendsCount: 5,
            journalsCount: 2,
            friendRequestsCountString: "3",
            sportsGroundsCountString: "4",
            addedSportsGrounds: nil
        )
    }
}

extension UserModel {
    static var preview: UserModel { .init(.preview) }
}

extension EventResponse {
    static var preview: EventResponse {
        .init(
            id: 4414,
            title: "Открытая тренировка участников SOTKA и воркаутеров #2 в 2022 году",
            eventDescription: "!!! ВРЕМЯ ТРЕНИРОВКИ - 12:00",
            fullAddress: nil,
            createDate: "2022-10-16T09:00:00+00:00",
            modifyDate: "2022-10-16T09:00:00+00:00",
            beginDate: "2022-10-16T09:00:00+00:00",
            countryID: 17,
            cityID: 1,
            commentsCount: 2,
            previewImageStringURL: "https://workout.su/thumbs/6_100x100_FFFFFF//uploads/userfiles/2022/10/2022-10-12-21-10-42-skz.jpg",
            sportsGroundID: 5464,
            latitude: "55.72681766162947",
            longitude: "37.50063106774381",
            participantsCount: 3,
            isCurrent: false,
            photos: [
                .init(
                    id: 1,
                    stringURL: "https://workout.su/uploads/userfiles/2022/10/2022-10-12-21-10-42-skz.jpg"
                )
            ],
            authorName: "Kahar",
            author: .preview,
            trainHereOptional: false
        )
    }
}

extension DialogResponse {
    static var preview: DialogResponse {
        .init(
            id: 88777,
            anotherUserImageStringURL: "https://workout.su/uploads/avatars/2019/03/2019-03-21-23-03-49-rjk.jpg",
            anotherUserName: "WasD",
            lastMessageText: "Ошибка 500 это про пустые ответы? Я написал серверным.",
            lastMessageDate: "2022-05-14T17:35:45+00:00",
            anotherUserID: 30,
            unreadCountOptional: 5,
            createdDate: "2022-04-25T18:47:46+00:00"
        )
    }
}

extension JournalResponse {
    static var preview: JournalResponse {
        .init(
            id: 21758,
            titleOptional: "Test title",
            lastMessageImage: "avatar_default",
            createDate: "2022-05-21T10:48:17+03:00",
            modifyDate: "2022-05-22T09:48:17+03:00",
            lastMessageDate: "2022-05-22T09:48:29+03:00",
            lastMessageText: "Test last message",
            ownerName: "ninenineone",
            itemsCount: 2,
            ownerID: 10367,
            viewAccess: 2,
            commentAccess: 2
        )
    }
}

extension JournalEntryResponse {
    static var preview: JournalEntryResponse {
        .init(
            id: .zero,
            journalID: .zero,
            authorID: 10367,
            authorName: "ninenineone",
            message: "Test text",
            createDate: "2011-03-16T12:55:29+03:00",
            modifyDate: "2022-05-21T10:48:17+03:00",
            authorImage: "avatar_default"
        )
    }
}

extension Int {
    static var previewUserID: Self { 30 }
}

extension TextFieldInForm.Mode: CaseIterable, Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .regular(systemImageName):
            hasher.combine(systemImageName)
        case .secure:
            break
        }
    }

    static func == (lhs: TextFieldInForm.Mode, rhs: TextFieldInForm.Mode) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    static var allCases: [TextFieldInForm.Mode] { [.regular(systemImageName: "person"), .secure] }
}
#endif
