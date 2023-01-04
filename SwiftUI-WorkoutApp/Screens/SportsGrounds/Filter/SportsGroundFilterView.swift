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
                if defaults.isAuthorized {
                    Section("Расположение") {
                        buttonForMyCity
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
        Button {
            filter = defaultFilter
        } label: {
            ButtonInFormLabel(title: "Сбросить фильтры")
        }
        .disabled(!canResetFilter)
    }

    var canResetFilter: Bool {
        filter.size.count < 3
        || filter.type.count < 3
        || filter.onlyMyCity != defaultFilter.onlyMyCity
    }
}

struct SportsGroundFilterView_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundFilterView(filter: .constant(.init()))
            .environmentObject(DefaultsService())
    }
}
