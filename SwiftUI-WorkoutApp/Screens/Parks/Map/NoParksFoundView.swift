import SWDesignSystem
import SwiftUI
import SWModels

extension ParksMapScreen {
    struct NoParksFoundView: View {
        let openCities: () -> Void
        let openFilter: () -> Void
        let model: NoParksFoundModel

        var body: some View {
            ZStack {
                if model.showNoParksFound {
                    VStack(spacing: 12) {
                        titleView
                        openCitiesButton
                        if model.isFilterEdited {
                            openFilterButton
                        }
                    }
                    .insideCardBackground()
                    .padding()
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
                }
            }
            .animation(.default, value: model.showNoParksFound)
        }
    }
}

private extension ParksMapScreen.NoParksFoundView {
    var titleView: some View {
        Text("Не нашли площадки для этого города")
            .foregroundStyle(Color.swMainText)
            .multilineTextAlignment(.center)
            .padding(.bottom, 8)
    }

    var openCitiesButton: some View {
        Button("Выбрать другой город", action: openCities)
            .buttonStyle(
                SWButtonStyle(
                    mode: model.isFilterEdited ? .tinted : .filled,
                    size: .large
                )
            )
    }

    var openFilterButton: some View {
        Button("Изменить фильтры", action: openFilter)
            .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
    }
}

#if DEBUG
#Preview("С фильтрами") {
    ParksMapScreen.NoParksFoundView(
        openCities: {
            print("открыть выбор городов")
        },
        openFilter: {
            print("открыть фильтры")
        },
        model: .previewWithFilter
    )
}

#Preview("Без фильтров") {
    ParksMapScreen.NoParksFoundView(
        openCities: {
            print("открыть выбор городов")
        },
        openFilter: {
            print("открыть фильтры")
        },
        model: .previewWithoutFilter
    )
}
#endif
