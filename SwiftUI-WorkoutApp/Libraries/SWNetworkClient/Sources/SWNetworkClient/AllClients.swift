import Foundation

/// Композиция всех протоколов клиентов для работы с API
public typealias AllClients = AuthClient & CommentsClient & CountriesClient & EventsClient & FriendsClient & JournalsClient &
    MessagesClient & ParksClient & PhotosClient & ProfileClient
