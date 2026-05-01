import Foundation
import SWModels

extension Photo {
    static func makePreviewList(count: Int) -> [Self] {
        (0 ..< count).map {
            .init(id: $0, stringURL: "avatar_default")
        }
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

extension Park {
    static var preview: Park {
        .init(
            id: 3,
            typeId: 6,
            sizeId: 2,
            address: "м. Партизанская, улица 2-я Советская",
            author: nil,
            cityId: 1,
            commentsCount: 1,
            createDate: "2011-03-07T22:55:15+03:00",
            latitude: "55.795396",
            longitude: "37.762597",
            name: "№3 Средняя Легендарная",
            photosOptional: [
                .init(id: 1, stringURL: "https://workout.su/uploads/userfiles/измайлово.jpg"),
                .init(id: 2, stringURL: "https://workout.su/uploads/userfiles/измайлово (2).jpg"),
                .init(id: 3, stringURL: "https://workout.su/uploads/userfiles/измайлово-1.jpg"),
                .init(id: 4, stringURL: "https://workout.su/uploads/userfiles/измайлово-3.jpg"),
                .init(id: 5, stringURL: "https://workout.su/uploads/userfiles/измайлово-2.jpg"),
                .init(id: 6, stringURL: "https://workout.su/uploads/userfiles/измайлово-4.jpg")
            ],
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
            id: 24798,
            userName: "Workouter",
            fullName: "",
            email: "test@mail.ru",
            imageStringURL: "https://workout.su/uploads/avatars/2019/10/2019-10-07-01-10-08-yow.jpg",
            birthDateIsoString: "1989-11-25",
            cityId: 1,
            countryId: 17,
            genderCode: 0,
            friendsCount: 5,
            journalsCount: 2,
            parksCountString: "4",
            addedParks: nil
        )
    }

    static var previewForSearch: UserResponse {
        .init(
            id: 10367,
            userName: "Workout-Man",
            fullName: "TestUser",
            email: "testuser@example.com",
            imageStringURL: "https://workout.su/uploads/avatars/2023/01/2023-01-06-16-01-16-qyj.png",
            birthDateIsoString: "1992-08-12",
            cityId: 129,
            countryId: 17,
            genderCode: 0,
            friendsCount: 9,
            journalsCount: 3,
            parksCountString: "2",
            addedParks: [
                .init(
                    id: 12705,
                    typeId: 2,
                    sizeId: 2,
                    address: "Терренкур",
                    author: nil,
                    cityId: 129,
                    commentsCount: 4,
                    createDate: nil,
                    latitude: "43.54807742875423",
                    longitude: "39.77927360687385",
                    name: "№12705 Средняя Современная",
                    photosOptional: nil,
                    preview: "https://workout.su/uploads/userfiles/2023/11/2023-11-18-11-11-19-htm.jpg",
                    usersTrainHereCount: 1,
                    commentsOptional: nil,
                    usersTrainHere: nil,
                    trainHere: nil
                ),
                .init(
                    id: 13079,
                    typeId: 2,
                    sizeId: 1,
                    address: "Сочи, Лесная улица 8",
                    author: nil,
                    cityId: 129,
                    commentsCount: 0,
                    createDate: nil,
                    latitude: "43.56209058656023",
                    longitude: "39.76879335890034",
                    name: "№13079 Маленькая Современная",
                    photosOptional: nil,
                    preview: "https://workout.su/uploads/userfiles/2025/03/2025-03-15-16-03-33-nwd.jpg",
                    usersTrainHereCount: 0,
                    commentsOptional: nil,
                    usersTrainHere: nil,
                    trainHere: nil
                ),
                .init(
                    id: 13036,
                    typeId: 2,
                    sizeId: 2,
                    address: "Терренкур",
                    author: nil,
                    cityId: 129,
                    commentsCount: 0,
                    createDate: nil,
                    latitude: "43.54645389943022",
                    longitude: "39.784606137757656",
                    name: "№13036 Средняя Современная",
                    photosOptional: nil,
                    preview: "https://workout.su/uploads/userfiles/2025/02/2025-02-01-12-02-29-_sc.jpg",
                    usersTrainHereCount: 0,
                    commentsOptional: nil,
                    usersTrainHere: nil,
                    trainHere: nil
                ),
                .init(
                    id: 13171,
                    typeId: 2,
                    sizeId: 1,
                    address: "Терренкур",
                    author: nil,
                    cityId: 129,
                    commentsCount: 0,
                    createDate: nil,
                    latitude: "43.54935365969718",
                    longitude: "39.774987880704956",
                    name: "№13171 Маленькая Современная",
                    photosOptional: nil,
                    preview: "https://workout.su/uploads/userfiles/2025/06/2025-06-21-17-06-22-vo8.jpg",
                    usersTrainHereCount: 0,
                    commentsOptional: nil,
                    usersTrainHere: nil,
                    trainHere: nil
                ),
                .init(
                    id: 13170,
                    typeId: 2,
                    sizeId: 1,
                    address: "Курортный проспект, 100/6",
                    author: nil,
                    cityId: 129,
                    commentsCount: 0,
                    createDate: nil,
                    latitude: "43.55604705616232",
                    longitude: "39.7744707994896",
                    name: "№13170 Маленькая Современная",
                    photosOptional: nil,
                    preview: "https://workout.su/uploads/userfiles/2025/06/2025-06-21-16-06-21-2rx.jpg",
                    usersTrainHereCount: 0,
                    commentsOptional: nil,
                    usersTrainHere: nil,
                    trainHere: nil
                ),
                .init(
                    id: 13222,
                    typeId: 2,
                    sizeId: 2,
                    address: "Россия, Краснодарский край, Городской Округ Сочи, Сочи, Хостинский, Ясногорская улица, 34А",
                    author: nil,
                    cityId: 129,
                    commentsCount: 0,
                    createDate: nil,
                    latitude: "43.56682552795774",
                    longitude: "39.768487355120904",
                    name: "№13222 Средняя Современная",
                    photosOptional: nil,
                    preview: "https://workout.su/uploads/userfiles/2025/09/2025-09-28-11-09-21-r5a.jpg",
                    usersTrainHereCount: 0,
                    commentsOptional: nil,
                    usersTrainHere: nil,
                    trainHere: nil
                )
            ]
        )
    }

    static var previewFriends: [UserResponse] {
        Array(previewList.prefix(upTo: 10))
    }

    static var previewFriendRequests: [UserResponse] {
        Array(UserResponse.previewList.suffix(from: 11))
    }

    static var previewList: [UserResponse] {
        [
            .init(
                id: 80630,
                userName: "111Fisher111",
                fullName: "",
                email: nil,
                imageStringURL: "https://workout.su/uploads/avatars/2019/03/2019-03-02-00-03-11-inh.jpg",
                birthDateIsoString: nil,
                cityId: 504,
                countryId: 22,
                genderCode: nil,
                friendsCount: nil,
                journalsCount: nil,
                parksCountString: nil,
                addedParks: nil
            ),
            .init(
                id: 102140,
                userName: "123123q",
                fullName: "123123q",
                email: nil,
                imageStringURL: "https://workout.su/img/avatar_default.jpg",
                birthDateIsoString: nil,
                cityId: 601,
                countryId: 17,
                genderCode: nil,
                friendsCount: nil,
                journalsCount: nil,
                parksCountString: nil,
                addedParks: nil
            ),
            .init(
                id: 65278,
                userName: "123456q",
                fullName: "",
                email: nil,
                imageStringURL: "https://workout.su/img/avatar_default.jpg",
                birthDateIsoString: nil,
                cityId: 23,
                countryId: 17,
                genderCode: nil,
                friendsCount: nil,
                journalsCount: nil,
                parksCountString: nil,
                addedParks: nil
            ),
            .init(
                id: 81099,
                userName: "13Ivan05",
                fullName: "",
                email: nil,
                imageStringURL: "https://workout.su/img/avatar_default.jpg",
                birthDateIsoString: nil,
                cityId: 8219,
                countryId: 17,
                genderCode: nil,
                friendsCount: nil,
                journalsCount: nil,
                parksCountString: nil,
                addedParks: nil
            ),
            .init(
                id: 75571,
                userName: "13platinum",
                fullName: "",
                email: nil,
                imageStringURL: "https://workout.su/img/avatar_default.jpg",
                birthDateIsoString: nil,
                cityId: 589,
                countryId: 17,
                genderCode: nil,
                friendsCount: nil,
                journalsCount: nil,
                parksCountString: nil,
                addedParks: nil
            ),
            .init(
                id: 102704,
                userName: "1973Alexander",
                fullName: "1973Alexander",
                email: nil,
                imageStringURL: "https://workout.su/img/avatar_default.jpg",
                birthDateIsoString: nil,
                cityId: 55,
                countryId: 17,
                genderCode: nil,
                friendsCount: nil,
                journalsCount: nil,
                parksCountString: nil,
                addedParks: nil
            ),
            .init(
                id: 11373,
                userName: "1drag1",
                fullName: "Александр",
                email: nil,
                imageStringURL: "https://workout.su/uploads/avatars/2017/07/2017-07-31-23-07-36-lji.jpg",
                birthDateIsoString: nil,
                cityId: 145,
                countryId: 17,
                genderCode: nil,
                friendsCount: nil,
                journalsCount: nil,
                parksCountString: nil,
                addedParks: nil
            ),
            .init(
                id: 94953,
                userName: "1myf1",
                fullName: "1myf1",
                email: nil,
                imageStringURL: "https://workout.su/img/avatar_default.jpg",
                birthDateIsoString: nil,
                cityId: 589,
                countryId: 17,
                genderCode: nil,
                friendsCount: nil,
                journalsCount: nil,
                parksCountString: nil,
                addedParks: nil
            ),
            .init(
                id: 62798,
                userName: "1RUSMAN1",
                fullName: "Евгений",
                email: nil,
                imageStringURL: "https://workout.su/img/avatar_default.jpg",
                birthDateIsoString: nil,
                cityId: 1,
                countryId: 17,
                genderCode: nil,
                friendsCount: nil,
                journalsCount: nil,
                parksCountString: nil,
                addedParks: nil
            ),
            .init(
                id: 65910,
                userName: "1VENGR1",
                fullName: "Артём",
                email: nil,
                imageStringURL: "https://workout.su/img/avatar_default.jpg",
                birthDateIsoString: nil,
                cityId: 92,
                countryId: 17,
                genderCode: nil,
                friendsCount: nil,
                journalsCount: nil,
                parksCountString: nil,
                addedParks: nil
            ),
            .init(
                id: 53047,
                userName: "1_Andrei_1",
                fullName: "Андрей",
                email: nil,
                imageStringURL: "https://workout.su/uploads/avatars/2018/12/2018-12-29-12-12-31-q5o.jpg",
                birthDateIsoString: nil,
                cityId: 130,
                countryId: 17,
                genderCode: nil,
                friendsCount: nil,
                journalsCount: nil,
                parksCountString: nil,
                addedParks: nil
            ),
            .init(
                id: 63359,
                userName: "3452",
                fullName: "Рустам",
                email: nil,
                imageStringURL: "https://workout.su/uploads/avatars/2018/07/2018-07-31-12-07-58-yno.jpg",
                birthDateIsoString: nil,
                cityId: 141,
                countryId: 17,
                genderCode: nil,
                friendsCount: nil,
                journalsCount: nil,
                parksCountString: nil,
                addedParks: nil
            ),
            .init(
                id: 67686,
                userName: "347430",
                fullName: "",
                email: nil,
                imageStringURL: "https://workout.su/img/avatar_default.jpg",
                birthDateIsoString: nil,
                cityId: 112,
                countryId: 17,
                genderCode: nil,
                friendsCount: nil,
                journalsCount: nil,
                parksCountString: nil,
                addedParks: nil
            ),
            .init(
                id: 67168,
                userName: "34urupinsk",
                fullName: "",
                email: nil,
                imageStringURL: "https://workout.su/img/avatar_default.jpg",
                birthDateIsoString: nil,
                cityId: 8161,
                countryId: 17,
                genderCode: nil,
                friendsCount: nil,
                journalsCount: nil,
                parksCountString: nil,
                addedParks: nil
            ),
            .init(
                id: 64379,
                userName: "3maxden",
                fullName: "Денис",
                email: nil,
                imageStringURL: "https://workout.su/img/avatar_default.jpg",
                birthDateIsoString: nil,
                cityId: 2,
                countryId: 17,
                genderCode: nil,
                friendsCount: nil,
                journalsCount: nil,
                parksCountString: nil,
                addedParks: nil
            ),
            .init(
                id: 100381,
                userName: "40et",
                fullName: "40et",
                email: nil,
                imageStringURL: "https://workout.su/img/avatar_default.jpg",
                birthDateIsoString: nil,
                cityId: 19,
                countryId: 17,
                genderCode: nil,
                friendsCount: nil,
                journalsCount: nil,
                parksCountString: nil,
                addedParks: nil
            ),
            .init(
                id: 79726,
                userName: "4171841718S",
                fullName: "",
                email: nil,
                imageStringURL: "https://workout.su/img/avatar_default.jpg",
                birthDateIsoString: nil,
                cityId: 8412,
                countryId: 17,
                genderCode: nil,
                friendsCount: nil,
                journalsCount: nil,
                parksCountString: nil,
                addedParks: nil
            )
        ]
    }
}

extension EventResponse {
    static var preview: EventResponse {
        .init(
            id: 4414,
            title: "Открытая тренировка участников SOTKA и воркаутеров #2 в 2022 году",
            eventDescription: "!!! ВРЕМЯ ТРЕНИРОВКИ - 12:00",
            fullAddress: nil,
            beginDate: "2022-10-16T09:00:00+00:00",
            countryId: 17,
            cityId: 1,
            commentsCount: 2,
            previewImageStringURL: "https://workout.su/thumbs/6_100x100_FFFFFF//uploads/userfiles/2022/10/2022-10-12-21-10-42-skz.jpg",
            parkId: 5464,
            latitude: "55.72681766162947",
            longitude: "37.50063106774381",
            participantsCount: 3,
            isCurrent: false,
            photosOptional: [
                .init(
                    id: 1,
                    stringURL: "https://workout.su/uploads/userfiles/2022/10/2022-10-12-21-10-42-skz.jpg"
                )
            ],
            author: .preview,
            trainHereOptional: false
        )
    }

    static var previewList: [EventResponse] {
        let vasilenAuthor = UserResponse(
            id: 4646,
            userName: "VASILEN",
            fullName: nil,
            email: nil,
            imageStringURL: "https://workout.su/uploads/avatars/2018/06/2018-06-20-15-06-12-whv.png",
            birthDateIsoString: nil,
            cityId: nil,
            countryId: nil,
            genderCode: nil,
            friendsCount: nil,
            journalsCount: nil,
            parksCountString: nil,
            addedParks: nil
        )

        return [
            .init(
                id: 4699,
                title: "Тестирование максимумов | Открытая Воскресная Тренировка #48 в 2025 году (участники SOTKA, воркаутеры, все желающие)",
                eventDescription: "<i data-ed3=\"3\"></i><p>ВРЕМЯ ТРЕНИРОВКИ - 10:00</p><p>МЕСТО - ПАРК ПОБЕДЫ</p><p><br></p><p>Приложен маршрут от метро Минская.</p><p><br></p><p>Если что, у нас есть беседа в ТГ, чтобы можно было что-то оперативно спросить/уточнить/договориться - <a href=\"https://t.me/swmos\" target=\"_blank\">t.me/swmos</a></p><p><br></p><p>---</p><p><br></p><p>Воркаутеры и участники программы SOTKA в очередной раз соберутся для тренировки, общения и обмена опытом. Если у кого есть желание присоединиться, чтобы потренироваться вместе с нами в дружеской атмосфере старого доброго уличного воркаута, будем рады всем)</p><p><br></p><p>ДА, ПРИЙТИ МОЖНО, ДАЖЕ С ДЕТЬМИ, ДРУЗЬЯМИ, СВОИМ МОЛОДЫМ ЧЕЛОВЕКОМ И РОДИТЕЛЯМИ. МЫ БУДЕМ РАДЫ ВСЕМ!</p><p>ДА, ДАЖЕ, ЕСЛИ ВЫ НИКОГО НЕ ЗНАЕТЕ И НИЧЕГО НЕ УМЕЕТЕ (потому что мы сами друг с другом знакомимся и ничего феерического не умеем)!</p><p>ДА, ДАЖЕ, ЕСЛИ УРОВЕНЬ НА НУЛЕ!</p><p>ДА, ДАЖЕ, ЕСЛИ ВЫ ИЗ ДРУГОГО ГОРОДА, СЕЛА, ДЕРЕВНИ, ПЛАНЕТЫ!</p><p>ДА, МОЖНО ДАЖЕ ОПОЗДАТЬ (ничего страшного, потому что мы находимся там порядка двух часов)!</p><p>ДА, ЭТО БЕСПЛАТНО (потому что мы ничего не делаем)!</p><p><br></p><p>Главное - это ваше желание тренироваться, остальному научим, расскажем и покажем) мы даже колонку для музончика притащим, так что будет очень приятно, интересно и полезно.</p>",
                fullAddress: nil,
                beginDate: "2025-11-23T07:00:00+00:00",
                countryId: 17,
                cityId: 1,
                commentsCount: 0,
                previewImageStringURL: "https://workout.su/thumbs/6_100x100_FFFFFF//uploads/userfiles/2025/11/2025-11-18-22-11-33-waf.jpg",
                parkId: 5464,
                latitude: "55.72681766162947",
                longitude: "37.50063106774381",
                participantsCount: 1,
                isCurrent: false,
                photosOptional: [
                    .init(id: 1, stringURL: "https://workout.su/uploads/userfiles/2025/11/2025-11-18-22-11-33-waf.jpg"),
                    .init(id: 2, stringURL: "https://workout.su/uploads/userfiles/2025/11/2025-11-18-22-11-41-k0p.png"),
                    .init(id: 3, stringURL: "https://workout.su/uploads/userfiles/2025/11/2025-11-18-22-11-41-e12.png")
                ],
                author: vasilenAuthor,
                trainHereOptional: false
            ),
            .init(
                id: 4698,
                title: "Открытая Воскресная Тренировка #47 в 2025 году (участники SOTKA, воркаутеры, все желающие)",
                eventDescription: "<i data-ed3=\"3\"></i><p>ВРЕМЯ ТРЕНИРОВКИ - 10:00</p><p>МЕСТО - ПАРК ПОБЕДЫ</p><p><br></p><p>Приложен маршрут от метро Минская.</p><p><br></p><p>Если что, у нас есть беседа в ТГ, чтобы можно было что-то оперативно спросить/уточнить/договориться - <a href=\"https://t.me/swmos\" target=\"_blank\">t.me/swmos</a></p><p><br></p><p>---</p><p><br></p><p>Воркаутеры и участники программы SOTKA в очередной раз соберутся для тренировки, общения и обмена опытом. Если у кого есть желание присоединиться, чтобы потренироваться вместе с нами в дружеской атмосфере старого доброго уличного воркаута, будем рады всем)</p><p><br></p><p>ДА, ПРИЙТИ МОЖНО, ДАЖЕ С ДЕТЬМИ, ДРУЗЬЯМИ, СВОИМ МОЛОДЫМ ЧЕЛОВЕКОМ И РОДИТЕЛЯМИ. МЫ БУДЕМ РАДЫ ВСЕМ!</p><p>ДА, ДАЖЕ, ЕСЛИ ВЫ НИКОГО НЕ ЗНАЕТЕ И НИЧЕГО НЕ УМЕЕТЕ (потому что мы сами друг с другом знакомимся и ничего феерического не умеем)!</p><p>ДА, ДАЖЕ, ЕСЛИ УРОВЕНЬ НА НУЛЕ!</p><p>ДА, ДАЖЕ, ЕСЛИ ВЫ ИЗ ДРУГОГО ГОРОДА, СЕЛА, ДЕРЕВНИ, ПЛАНЕТЫ!</p><p>ДА, МОЖНО ДАЖЕ ОПОЗДАТЬ (ничего страшного, потому что мы находимся там порядка двух часов)!</p><p>ДА, ЭТО БЕСПЛАТНО (потому что мы ничего не делаем)!</p><p><br></p><p>Главное - это ваше желание тренироваться, остальному научим, расскажем и покажем) мы даже колонку для музончика притащим, так что будет очень приятно, интересно и полезно.</p>",
                fullAddress: nil,
                beginDate: "2025-11-16T07:00:00+00:00",
                countryId: 17,
                cityId: 1,
                commentsCount: 0,
                previewImageStringURL: "https://workout.su/thumbs/6_100x100_FFFFFF//uploads/userfiles/2025/11/2025-11-10-21-11-44-l_u.jpg",
                parkId: 5464,
                latitude: "55.72681766162947",
                longitude: "37.50063106774381",
                participantsCount: 1,
                isCurrent: false,
                photosOptional: [
                    .init(id: 1, stringURL: "https://workout.su/uploads/userfiles/2025/11/2025-11-10-21-11-44-l_u.jpg"),
                    .init(id: 2, stringURL: "https://workout.su/uploads/userfiles/2025/11/2025-11-10-21-11-13-pq1.png"),
                    .init(id: 3, stringURL: "https://workout.su/uploads/userfiles/2025/11/2025-11-10-21-11-38-smk.png")
                ],
                author: vasilenAuthor,
                trainHereOptional: false
            ),
            .init(
                id: 4695,
                title: "Открытая Воскресная Тренировка #46 в 2025 году (участники SOTKA, воркаутеры, все желающие)",
                eventDescription: "<i data-ed3=\"3\"></i><p>ВРЕМЯ ТРЕНИРОВКИ - 10:00</p><p>МЕСТО - ПАРК ПОБЕДЫ</p><p><br></p><p>Приложен маршрут от метро Минская.</p><p><br></p><p>Если что, у нас есть беседа в ТГ, чтобы можно было что-то оперативно спросить/уточнить/договориться - <a href=\"https://t.me/swmos\" target=\"_blank\">t.me/swmos</a></p><p><br></p><p>---</p><p><br></p><p>Воркаутеры и участники программы SOTKA в очередной раз соберутся для тренировки, общения и обмена опытом. Если у кого есть желание присоединиться, чтобы потренироваться вместе с нами в дружеской атмосфере старого доброго уличного воркаута, будем рады всем)</p><p><br></p><p>ДА, ПРИЙТИ МОЖНО, ДАЖЕ С ДЕТЬМИ, ДРУЗЬЯМИ, СВОИМ МОЛОДЫМ ЧЕЛОВЕКОМ И РОДИТЕЛЯМИ. МЫ БУДЕМ РАДЫ ВСЕМ!</p><p>ДА, ДАЖЕ, ЕСЛИ ВЫ НИКОГО НЕ ЗНАЕТЕ И НИЧЕГО НЕ УМЕЕТЕ (потому что мы сами друг с другом знакомимся и ничего феерического не умеем)!</p><p>ДА, ДАЖЕ, ЕСЛИ УРОВЕНЬ НА НУЛЕ!</p><p>ДА, ДАЖЕ, ЕСЛИ ВЫ ИЗ ДРУГОГО ГОРОДА, СЕЛА, ДЕРЕВНИ, ПЛАНЕТЫ!</p><p>ДА, МОЖНО ДАЖЕ ОПОЗДАТЬ (ничего страшного, потому что мы находимся там порядка двух часов)!</p><p>ДА, ЭТО БЕСПЛАТНО (потому что мы ничего не делаем)!</p><p><br></p><p>Главное - это ваше желание тренироваться, остальному научим, расскажем и покажем) мы даже колонку для музончика притащим, так что будет очень приятно, интересно и полезно.</p>",
                fullAddress: nil,
                beginDate: "2025-11-09T07:00:00+00:00",
                countryId: 17,
                cityId: 1,
                commentsCount: 0,
                previewImageStringURL: "https://workout.su/thumbs/6_100x100_FFFFFF//uploads/userfiles/2025/11/2025-11-05-21-11-21-4nq.jpg",
                parkId: 5464,
                latitude: "55.72681766162947",
                longitude: "37.50063106774381",
                participantsCount: 1,
                isCurrent: false,
                photosOptional: [
                    .init(id: 1, stringURL: "https://workout.su/uploads/userfiles/2025/11/2025-11-05-21-11-21-4nq.jpg"),
                    .init(id: 2, stringURL: "https://workout.su/uploads/userfiles/2025/11/2025-11-05-21-11-59-grr.png"),
                    .init(id: 3, stringURL: "https://workout.su/uploads/userfiles/2025/11/2025-11-05-21-11-59-grn.png")
                ],
                author: vasilenAuthor,
                trainHereOptional: false
            ),
            .init(
                id: 4694,
                title: "Открытая Воскресная Тренировка #45 в 2025 году (участники SOTKA, воркаутеры, все желающие)",
                eventDescription: "<i data-ed3=\"3\"></i><p>ВРЕМЯ ТРЕНИРОВКИ - 10:00</p><p>МЕСТО - ПАРК ПОБЕДЫ</p><p><br></p><p>Приложен маршрут от метро Минская.</p><p><br></p><p>Если что, у нас есть беседа в ТГ, чтобы можно было что-то оперативно спросить/уточнить/договориться - <a href=\"https://t.me/swmos\" target=\"_blank\">t.me/swmos</a></p><p><br></p><p>---</p><p><br></p><p>Воркаутеры и участники программы SOTKA в очередной раз соберутся для тренировки, общения и обмена опытом. Если у кого есть желание присоединиться, чтобы потренироваться вместе с нами в дружеской атмосфере старого доброго уличного воркаута, будем рады всем)</p><p><br></p><p>ДА, ПРИЙТИ МОЖНО, ДАЖЕ С ДЕТЬМИ, ДРУЗЬЯМИ, СВОИМ МОЛОДЫМ ЧЕЛОВЕКОМ И РОДИТЕЛЯМИ. МЫ БУДЕМ РАДЫ ВСЕМ!</p><p>ДА, ДАЖЕ, ЕСЛИ ВЫ НИКОГО НЕ ЗНАЕТЕ И НИЧЕГО НЕ УМЕЕТЕ (потому что мы сами друг с другом знакомимся и ничего феерического не умеем)!</p><p>ДА, ДАЖЕ, ЕСЛИ УРОВЕНЬ НА НУЛЕ!</p><p>ДА, ДАЖЕ, ЕСЛИ ВЫ ИЗ ДРУГОГО ГОРОДА, СЕЛА, ДЕРЕВНИ, ПЛАНЕТЫ!</p><p>ДА, МОЖНО ДАЖЕ ОПОЗДАТЬ (ничего страшного, потому что мы находимся там порядка двух часов)!</p><p>ДА, ЭТО БЕСПЛАТНО (потому что мы ничего не делаем)!</p><p><br></p><p>Главное - это ваше желание тренироваться, остальному научим, расскажем и покажем) мы даже колонку для музончика притащим, так что будет очень приятно, интересно и полезно.</p>",
                fullAddress: nil,
                beginDate: "2025-11-02T07:00:00+00:00",
                countryId: 17,
                cityId: 1,
                commentsCount: 0,
                previewImageStringURL: "https://workout.su/thumbs/6_100x100_FFFFFF//uploads/userfiles/2025/10/2025-10-27-20-10-45-mq9.jpg",
                parkId: 5464,
                latitude: "55.72681766162947",
                longitude: "37.50063106774381",
                participantsCount: 1,
                isCurrent: false,
                photosOptional: [
                    .init(id: 1, stringURL: "https://workout.su/uploads/userfiles/2025/10/2025-10-27-20-10-45-mq9.jpg"),
                    .init(id: 2, stringURL: "https://workout.su/uploads/userfiles/2025/10/2025-10-27-20-10-53-wu6.png"),
                    .init(id: 3, stringURL: "https://workout.su/uploads/userfiles/2025/10/2025-10-27-20-10-53-aig.png")
                ],
                author: vasilenAuthor,
                trainHereOptional: false
            ),
            .init(
                id: 4693,
                title: "Открытая Воскресная Тренировка #44 в 2025 году (участники SOTKA, воркаутеры, все желающие)",
                eventDescription: "<i data-ed3=\"3\"></i><p>ВРЕМЯ ТРЕНИРОВКИ - 10:00</p><p>МЕСТО - ПАРК ПОБЕДЫ</p><p><br></p><p>Приложен маршрут от метро Минская.</p><p><br></p><p>Если что, у нас есть беседа в ТГ, чтобы можно было что-то оперативно спросить/уточнить/договориться - <a href=\"https://t.me/swmos\" target=\"_blank\">t.me/swmos</a></p><p><br></p><p>---</p><p><br></p><p>Воркаутеры и участники программы SOTKA в очередной раз соберутся для тренировки, общения и обмена опытом. Если у кого есть желание присоединиться, чтобы потренироваться вместе с нами в дружеской атмосфере старого доброго уличного воркаута, будем рады всем)</p><p><br></p><p>ДА, ПРИЙТИ МОЖНО, ДАЖЕ С ДЕТЬМИ, ДРУЗЬЯМИ, СВОИМ МОЛОДЫМ ЧЕЛОВЕКОМ И РОДИТЕЛЯМИ. МЫ БУДЕМ РАДЫ ВСЕМ!</p><p>ДА, ДАЖЕ, ЕСЛИ ВЫ НИКОГО НЕ ЗНАЕТЕ И НИЧЕГО НЕ УМЕЕТЕ (потому что мы сами друг с другом знакомимся и ничего феерического не умеем)!</p><p>ДА, ДАЖЕ, ЕСЛИ УРОВЕНЬ НА НУЛЕ!</p><p>ДА, ДАЖЕ, ЕСЛИ ВЫ ИЗ ДРУГОГО ГОРОДА, СЕЛА, ДЕРЕВНИ, ПЛАНЕТЫ!</p><p>ДА, МОЖНО ДАЖЕ ОПОЗДАТЬ (ничего страшного, потому что мы находимся там порядка двух часов)!</p><p>ДА, ЭТО БЕСПЛАТНО (потому что мы ничего не делаем)!</p><p><br></p><p>Главное - это ваше желание тренироваться, остальному научим, расскажем и покажем) мы даже колонку для музончика притащим, так что будет очень приятно, интересно и полезно.</p>",
                fullAddress: nil,
                beginDate: "2025-10-26T07:00:00+00:00",
                countryId: 17,
                cityId: 1,
                commentsCount: 0,
                previewImageStringURL: "https://workout.su/thumbs/6_100x100_FFFFFF//uploads/userfiles/2025/10/2025-10-20-21-10-28--a2.jpg",
                parkId: 5464,
                latitude: "55.72681766162947",
                longitude: "37.50063106774381",
                participantsCount: 1,
                isCurrent: false,
                photosOptional: [
                    .init(id: 1, stringURL: "https://workout.su/uploads/userfiles/2025/10/2025-10-20-21-10-28--a2.jpg"),
                    .init(id: 2, stringURL: "https://workout.su/uploads/userfiles/2025/10/2025-10-20-21-10-42-hoa.png"),
                    .init(id: 3, stringURL: "https://workout.su/uploads/userfiles/2025/10/2025-10-20-21-10-42-piy.png")
                ],
                author: vasilenAuthor,
                trainHereOptional: false
            )
        ]
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
            anotherUserId: 30,
            unreadCountOptional: 5
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
            itemsCount: 2,
            ownerId: 10367,
            viewAccess: 2,
            commentAccess: 2
        )
    }
}

extension JournalEntryResponse {
    static var preview: JournalEntryResponse {
        .init(
            id: 0,
            journalId: 0,
            authorId: 10367,
            authorName: "ninenineone",
            message: "Test text",
            createDate: "2011-03-16T12:55:29+03:00",
            modifyDate: "2022-05-21T10:48:17+03:00",
            authorImage: "avatar_default"
        )
    }
}

extension Int {
    static var previewUserId: Self {
        30
    }
}

extension NoParksFoundModel {
    static let previewWithFilter = Self(
        isFilterEdited: true,
        isFilteredParksEmpty: true,
        didParksManagerLoad: true,
        isLoading: false
    )

    static let previewWithoutFilter = Self(
        isFilterEdited: false,
        isFilteredParksEmpty: true,
        didParksManagerLoad: true,
        isLoading: false
    )
}
