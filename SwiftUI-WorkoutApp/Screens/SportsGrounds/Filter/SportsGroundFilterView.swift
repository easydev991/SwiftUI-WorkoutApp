import SwiftUI
import ShortAddressService

struct SportsGroundFilterView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @Binding var filter: SportsGroundFilter
    private let defaultFilter = SportsGroundFilter()

    var body: some View {
        ContentInSheet(title: "Фильтр площадок", spacing: .zero) {
            Form {
                Section("Размер") {
                    ForEach(defaultFilter.size, id: \.self) { groundSize in
                        buttonFor(groundSize)
                    }
                }
                Section("Тип") {
                    ForEach(defaultFilter.grade, id: \.self) { groundGrade in
                        buttonFor(groundGrade)
                    }
                }
                if defaults.isAuthorized {
                    Section {
                        buttonForMyCity
                    } header: {
                        Text("Расположение")
                    } footer: {
                        Text(footerCityText)
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
                guard filter.size.count > 1 else { return }
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

    func buttonFor(_ grade: SportsGroundGrade) -> some View {
        Button {
            if filter.grade.contains(grade) {
                guard filter.grade.count > 1 else { return }
                filter.grade = filter.grade.filter { $0 != grade }
            } else {
                filter.grade.append(grade)
            }
        } label: {
            TextWithCheckmark(
                title: SportsGroundGrade(id: grade.code).rawValue,
                showMark: filter.grade.contains(grade)
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

    var footerCityText: String {
        var resultString = ""
        let currentCity = filter.currentCity
        let userProfileCity = ShortAddressService(defaults.mainUserCountryID, defaults.mainUserCityID).cityName
        if let userProfileCity {
            resultString += "Твой город в профиле: \(userProfileCity)"
        }
        if let currentCity, currentCity != userProfileCity {
            resultString += "\nТекущий город: \(currentCity)"
        }
        return resultString
    }

    var canResetFilter: Bool {
        let isGroundFilterDifferent =
        filter.size.count != defaultFilter.size.count
        || filter.grade.count != defaultFilter.grade.count
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
