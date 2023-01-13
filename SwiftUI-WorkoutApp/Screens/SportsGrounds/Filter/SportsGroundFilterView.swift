import SwiftUI

struct SportsGroundFilterView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @Binding var filter: SportsGroundFilter
    private let defaultFilter = SportsGroundFilter()

    var body: some View {
        ContentInSheet(title: "Фильтр площадок", spacing: .zero) {
            Form {
                Section("Размер") {
                    ForEach(defaultFilter.size, id: \.self) { size in
                        buttonFor(size)
                    }
                }
                Section("Тип") {
                    ForEach(defaultFilter.type, id: \.self) { type in
                        buttonFor(type)
                    }
                }
                if defaults.isAuthorized, let cityName = cityName {
                    Section {
                        buttonForMyCity
                    } header: {
                        Text("Расположение")
                    } footer: {
                        Text("Твой город в профиле: \(cityName)")
                    }
                }
                resetFilterButton
            }
        }
    }
}

private extension SportsGroundFilterView {
    func buttonFor(_ size: SportsGroundSize) -> some View {
        Button {
            if filter.size.contains(size) {
                filter.size = filter.size.filter { $0 != size }
            } else {
                filter.size.append(size)
            }
        } label: {
            TextWithCheckmark(
                title: SportsGroundSize(id: size.code).rawValue,
                showMark: filter.size.contains(size)
            )
        }
    }

    func buttonFor(_ type: SportsGroundGrade) -> some View {
        Button {
            if filter.type.contains(type) {
                filter.type = filter.type.filter { $0 != type }
            } else {
                filter.type.append(type)
            }
        } label: {
            TextWithCheckmark(
                title: SportsGroundGrade(id: type.code).rawValue,
                showMark: filter.type.contains(type)
            )
        }
    }

    var buttonForMyCity: some View {
        Button {
            filter.onlyMyCity.toggle()
        } label: {
            TextWithCheckmark(
                title: "Только для моего города",
                showMark: filter.onlyMyCity == defaultFilter.onlyMyCity
            )
        }
    }

    var resetFilterButton: some View {
        ButtonInForm("Сбросить фильтры") {
            filter = defaultFilter
        }
        .disabled(!canResetFilter)
    }

    var cityName: String? {
        try? ShortAddressService().cityName(with: defaults.mainUserCityID, in: defaults.mainUserCountryID)
    }

    var canResetFilter: Bool {
        let isGroundFilterDifferent =
        filter.size != defaultFilter.size
        || filter.type != defaultFilter.type
        let isCityFilterDifferent = defaults.isAuthorized
        ? filter.onlyMyCity != defaultFilter.onlyMyCity
        : false
        return isGroundFilterDifferent || isCityFilterDifferent
    }
}

#if DEBUG
struct SportsGroundFilterView_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundFilterView(filter: .constant(.init()))
            .environmentObject(DefaultsService())
    }
}
#endif
