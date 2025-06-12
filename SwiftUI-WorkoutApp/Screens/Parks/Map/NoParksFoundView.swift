import SWDesignSystem
import SwiftUI

extension ParksMapScreen {
    struct NoParksFoundView: View {
        let openCities: () -> Void
        let openFilter: () -> Void
        let isHidden: Bool

        var body: some View {
            ZStack {
                if !isHidden {
                    VStack(spacing: 12) {
                        titleView
                        openCitiesButton
                        openFilterButton
                    }
                    .insideCardBackground()
                    .padding()
                    .transition(.scale(scale: 0.5).combined(with: .opacity))
                }
            }
            .animation(.default, value: isHidden)
        }
    }
}

private extension ParksMapScreen.NoParksFoundView {
    var titleView: some View {
        Text("Не нашли площадки для этого города с выбранными фильтрами")
            .foregroundStyle(Color.swMainText)
            .multilineTextAlignment(.center)
            .padding(.bottom, 8)
    }

    var openCitiesButton: some View {
        Button("Выбрать другой город", action: openCities)
            .buttonStyle(SWButtonStyle(mode: .tinted, size: .large))
    }

    var openFilterButton: some View {
        Button("Изменить фильтры", action: openFilter)
            .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
    }
}

#if DEBUG
#Preview {
    ParksMapScreen.NoParksFoundView(
        openCities: {
            print("открыть выбор городов")
        },
        openFilter: {
            print("открыть фильтры")
        },
        isHidden: false
    )
}
#endif
