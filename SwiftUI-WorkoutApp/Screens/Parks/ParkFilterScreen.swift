import SWDesignSystem
import SwiftUI
import SWModels

struct ParkFilterScreen: View {
    @Environment(\.analyticsService) private var analytics
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var reviewService: ReviewService
    /// Фильтр на родительском экране
    @Binding private var filter: ParkFilterModel
    /// Локальный фильтр
    @State private var localFilter: ParkFilterModel
    private let allSizes = ParkSize.allCases
    private let allGrades = ParkGrade.allCases

    init(filter: Binding<ParkFilterModel>) {
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
                        resetButton
                        applyButton
                    }
                }
                .padding([.top, .horizontal])
            }
        }
        .trackScreen(.parkFilter)
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
            analytics.log(.userAction(action: .selectParkFilterSize(size: "\(size.rawValue)")))
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
            analytics.log(.userAction(action: .selectParkFilterType(type: "\(grade.rawValue)")))
        } label: {
            TextWithCheckmarkRowView(
                text: grade.description,
                isChecked: localFilter.grade.contains(grade)
            )
        }
    }

    var resetButton: some View {
        Button("Сбросить") {
            localFilter = .init()
        }
        .buttonStyle(SWButtonStyle(mode: .tinted, size: .large))
        .disabled(!localFilter.isEdited)
        .animation(.default, value: localFilter.isEdited)
    }

    var applyButton: some View {
        let canApply = localFilter != filter
        return Button("Применить") {
            filter = localFilter
            dismiss()
            reviewService.didApplyFilter()
        }
        .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
        .disabled(!canApply)
        .animation(.default, value: canApply)
    }
}

#if DEBUG
@available(iOS 17, *)
#Preview("Изначально пустой") {
    @Previewable @State var filter = ParkFilterModel()
    ParkFilterScreen(filter: $filter)
        .environmentObject(ReviewService())
}

@available(iOS 17, *)
#Preview("Изначально настроен") {
    @Previewable @State var filter = ParkFilterModel(size: [.large], grade: [.modern])
    ParkFilterScreen(filter: $filter)
        .environmentObject(ReviewService())
}
#endif
