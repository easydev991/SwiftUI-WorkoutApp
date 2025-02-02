import SWDesignSystem
import SwiftUI
import SWModels
import SWUtils

struct ParkFilterScreen: View {
    @Binding private var filter: Model
    private let allSizes = ParkSize.allCases
    private let allGrades = ParkGrade.allCases

    init(filter: Binding<Model>) {
        self._filter = filter
    }

    var body: some View {
        ContentInSheet(title: "Фильтр площадок", spacing: 0) {
            ScrollView {
                VStack(spacing: 32) {
                    SectionView(header: "Размер", mode: .card()) {
                        VStack(spacing: 0) {
                            ForEach(Array(zip(allSizes.indices, allSizes)), id: \.0) { index, parkSize in
                                buttonFor(parkSize)
                                    .withDivider(if: index != allSizes.endIndex - 1)
                            }
                        }
                    }
                    SectionView(
                        header: "Тип",
                        mode: .card()
                    ) {
                        VStack(spacing: 0) {
                            ForEach(Array(zip(allGrades.indices, allGrades)), id: \.0) { index, parkGrade in
                                buttonFor(parkGrade)
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

extension ParkFilterScreen {
    struct Model: Equatable {
        var size = ParkSize.allCases
        var grade = ParkGrade.allCases

        var isEdited: Bool {
            size.count < ParkSize.allCases.count || grade.count < ParkGrade.allCases.count
        }
    }
}

private extension ParkFilterScreen {
    func buttonFor(_ size: ParkSize) -> some View {
        Button {
            if filter.size.contains(size) {
                guard filter.size.count > 1 else { return }
                filter.size = filter.size.filter { $0 != size }
            } else {
                filter.size.append(size)
            }
        } label: {
            TextWithCheckmarkRowView(
                text: .init(ParkSize(id: size.code).rawValue),
                isChecked: filter.size.contains(size)
            )
        }
    }

    func buttonFor(_ grade: ParkGrade) -> some View {
        Button {
            if filter.grade.contains(grade) {
                guard filter.grade.count > 1 else { return }
                filter.grade = filter.grade.filter { $0 != grade }
            } else {
                filter.grade.append(grade)
            }
        } label: {
            TextWithCheckmarkRowView(
                text: .init(ParkGrade(id: grade.code).rawValue),
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
    ParkFilterScreen(filter: .constant(.init()))
}
#endif
