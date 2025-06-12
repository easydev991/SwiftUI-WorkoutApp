import SWDesignSystem
import SwiftUI
import SWModels

struct ParkFilterScreen: View {
    @Environment(\.dismiss) private var dismiss
    /// Фильтр на родительском экране
    @Binding private var filter: Model
    /// Локальный фильтр
    @State private var localFilter: Model
    private let allSizes = ParkSize.allCases
    private let allGrades = ParkGrade.allCases

    init(filter: Binding<Model>) {
        self._filter = filter
        self._localFilter = .init(initialValue: filter.wrappedValue)
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
                    VStack(spacing: 12) {
                        resetFilterButton
                        applyFilterButton
                    }
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
            if localFilter.size.contains(size) {
                guard localFilter.size.count > 1 else { return }
                localFilter.size = localFilter.size.filter { $0 != size }
            } else {
                localFilter.size.append(size)
            }
        } label: {
            TextWithCheckmarkRowView(
                text: size.description,
                isChecked: localFilter.size.contains(size)
            )
        }
    }

    func buttonFor(_ grade: ParkGrade) -> some View {
        Button {
            if localFilter.grade.contains(grade) {
                guard localFilter.grade.count > 1 else { return }
                localFilter.grade = localFilter.grade.filter { $0 != grade }
            } else {
                localFilter.grade.append(grade)
            }
        } label: {
            TextWithCheckmarkRowView(
                text: grade.description,
                isChecked: localFilter.grade.contains(grade)
            )
        }
    }

    var resetFilterButton: some View {
        Button("Сбросить") {
            localFilter = .init()
        }
        .buttonStyle(SWButtonStyle(mode: .tinted, size: .large))
        .disabled(!localFilter.isEdited)
    }

    var applyFilterButton: some View {
        Button("Применить") {
            filter = localFilter
            dismiss()
        }
        .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
        .disabled(localFilter == filter)
    }
}

#if DEBUG
@available(iOS 17, *)
#Preview {
    @Previewable @State var filter = ParkFilterScreen.Model()
    ParkFilterScreen(filter: $filter)
}
#endif
