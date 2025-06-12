import SwiftUI

/// Имитирует текстовое поле для поиска
public struct SWTextFieldSearchButton: View {
    private let titleKey: LocalizedStringKey
    private let showClearButton: Bool
    private let mainAction: () -> Void
    private let clearAction: () -> Void
    
    public init(
        _ titleKey: LocalizedStringKey,
        showClearButton: Bool = false,
        mainAction: @escaping () -> Void,
        clearAction: @escaping () -> Void
    ) {
        self.titleKey = titleKey
        self.showClearButton = showClearButton
        self.mainAction = mainAction
        self.clearAction = clearAction
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            Button(action: mainAction) {
                HStack(spacing: 6) {
                    Icons.Regular.magnifyingglass.view
                    Text(titleKey)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            if showClearButton {
                Button(action: clearAction) {
                    Icons.Regular.xmark.view
                        .symbolVariant(.circle.fill)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showClearButton)
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .foregroundStyle(Color.swSearchForeground)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.swSearchBackground)
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        SWTextFieldSearchButton(
            "Найти город",
            showClearButton: false,
            mainAction: { print("main action!") },
            clearAction: {}
        )
        SWTextFieldSearchButton(
            "Красноярск",
            showClearButton: true,
            mainAction: { print("main action!") },
            clearAction: { print("clear action") }
        )
    }
    .padding(.horizontal)
}
#endif
