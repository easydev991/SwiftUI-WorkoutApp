import Foundation

final class CreateOrEditEventViewModel: ObservableObject {
    @Published var eventInfo: EventResponse
    @Published var eventDate = Date()
    @Published var sportsGround: SportsGround
    @Published var countries = [Country]()
    @Published var cities = [City]()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var isSuccess = false
    private let userInfo: UserResponse

    init(with event: EventResponse?, for userInfo: UserResponse) {
        if let event = event {
            eventInfo = event
            sportsGround = event.sportsGround
        } else {
            eventInfo = .emptyValue
            sportsGround = .emptyValue
        }
        self.userInfo = userInfo
        makeCountryAndCityData(for: event)
    }

    var canSaveEvent: Bool {
        !eventInfo.formattedTitle.isEmpty
        && eventInfo.hasDescription
        && sportsGround.id != .zero
    }

    func saveEvent(with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
#warning("TODO: интеграция с сервером")
            isSuccess.toggle()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func selectCountry(_ country: Country) {
        eventInfo.countryID = Int(country.id)
        updateCityIfNeeded(for: country)
    }

    func clearErrorMessage() { errorMessage = "" }
}

private extension CreateOrEditEventViewModel {
    func makeCountryAndCityData(for event: EventResponse?) {
        let allCountries = Bundle.main.decodeJson(
            [Country].self,
            fileName: "countries.json"
        )
        guard let currentCountry = allCountries
            .first(where: { $0.id == userInfo.countryID?.description }) else {
            fatalError("Страна пользователя должна быть в списке")
        }
        countries = allCountries.sorted { $0.name < $1.name }
        cities = currentCountry.cities.sorted { $0.name < $1.name }
        if let event = event {
            eventInfo.countryID = event.countryID
            eventInfo.cityID = event.cityID
        } else {
            eventInfo.countryID = userInfo.countryID
            eventInfo.cityID = userInfo.cityID
        }
    }

    func updateCityIfNeeded(for country: Country) {
        if !country.cities.contains(where: { Int($0.id) == eventInfo.cityID }),
           let firstCity = country.cities.first {
            eventInfo.cityID = Int(firstCity.id)
            cities = country.cities
        }
    }
}
