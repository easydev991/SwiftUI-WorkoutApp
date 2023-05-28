import DesignSystem
import ShortAddressService
import SwiftUI
import SWModels

struct SportsGroundFilterView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @Binding private var filter: Model
    private let defaultFilter: Model

    init(filter: Binding<Model>, currentCity: String?) {
        self._filter = filter
        self.defaultFilter = .init(currentCity: currentCity)
    }

    var body: some View {
        ContentInSheet(title: "Фильтр площадок", spacing: .zero) {
            ScrollView {
                VStack(spacing: 32) {
                    SectionView(
                        header: "Размер",
                        mode: .card()
                    ) {
                        VStack(spacing: 0) {
                            ForEach(Array(zip(defaultFilter.size.indices, defaultFilter.size)), id: \.0) { index, groundSize in
                                buttonFor(groundSize)
                                    .withDivider(if: index != defaultFilter.size.endIndex - 1)
                            }
                        }
                    }
                    SectionView(
                        header: "Тип",
                        mode: .card()
                    ) {
                        VStack(spacing: 0) {
                            ForEach(Array(zip(defaultFilter.grade.indices, defaultFilter.grade)), id: \.0) { index, groundGrade in
                                buttonFor(groundGrade)
                                    .withDivider(if: index != defaultFilter.grade.endIndex - 1)
                            }
                        }
                    }
                    if defaults.isAuthorized {
                        SectionView(
                            header: "Расположение",
                            footer: footerCityText,
                            mode: .card()
                        ) {
                            buttonForMyCity
                        }
                    }
                    resetFilterButton
                }
                .padding([.top, .horizontal])
            }
        }
    }
}

extension SportsGroundFilterView {
    struct Model: Equatable {
        var size = SportsGroundSize.allCases
        var grade = SportsGroundGrade.allCases
        var onlyMyCity = true
        var currentCity: String?
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
            TextWithCheckmarkRowView(
                text: SportsGroundSize(id: size.code).rawValue,
                isChecked: filter.size.contains(size)
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
            TextWithCheckmarkRowView(
                text: SportsGroundGrade(id: grade.code).rawValue,
                isChecked: filter.grade.contains(grade)
            )
        }
    }

    var buttonForMyCity: some View {
        Button {
            filter.onlyMyCity.toggle()
        } label: {
            TextWithCheckmarkRowView(
                text: "Только для моего города",
                isChecked: filter.onlyMyCity == defaultFilter.onlyMyCity
            )
        }
    }

    var resetFilterButton: some View {
        Button("Сбросить фильтры") {
            filter = defaultFilter
        }
        .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
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
        SportsGroundFilterView(
            filter: .constant(.init()),
            currentCity: "Moscow"
        )
        .environmentObject(DefaultsService())
    }
}
#endif
