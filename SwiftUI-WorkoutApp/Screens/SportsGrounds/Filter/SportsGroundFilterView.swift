import ShortAddressService
import SWDesignSystem
import SwiftUI
import SWModels

struct SportsGroundFilterView: View {
    @Binding private var filter: Model
    private let allSizes = SportsGroundSize.allCases
    private let allGrades = SportsGroundGrade.allCases

    init(filter: Binding<Model>) {
        self._filter = filter
    }

    var body: some View {
        ContentInSheet(title: "Фильтр площадок", spacing: 0) {
            ScrollView {
                VStack(spacing: 32) {
                    SectionView(header: "Размер", mode: .card()) {
                        VStack(spacing: 0) {
                            ForEach(Array(zip(allSizes.indices, allSizes)), id: \.0) { index, groundSize in
                                buttonFor(groundSize)
                                    .withDivider(if: index != allSizes.endIndex - 1)
                            }
                        }
                    }
                    SectionView(
                        header: "Тип",
                        mode: .card()
                    ) {
                        VStack(spacing: 0) {
                            ForEach(Array(zip(allGrades.indices, allGrades)), id: \.0) { index, groundGrade in
                                buttonFor(groundGrade)
                                    .withDivider(if: index != allGrades.endIndex - 1)
                            }
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

        var isEdited: Bool {
            size.count < SportsGroundSize.allCases.count
                || grade.count < SportsGroundGrade.allCases.count
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
            TextWithCheckmarkRowView(
                text: .init(SportsGroundSize(id: size.code).rawValue),
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
                text: .init(SportsGroundGrade(id: grade.code).rawValue),
                isChecked: filter.grade.contains(grade)
            )
        }
    }

    var resetFilterButton: some View {
        Button("Сбросить фильтры") {
            filter = .init()
        }
        .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
        .disabled(!filter.isEdited)
    }
}

#if DEBUG
#Preview {
    SportsGroundFilterView(filter: .constant(.init()))
}
#endif
