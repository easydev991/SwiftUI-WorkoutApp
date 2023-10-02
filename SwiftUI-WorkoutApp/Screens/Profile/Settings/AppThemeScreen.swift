import DesignSystem
import SwiftUI

/// Экран "Тема приложения"
struct AppThemeScreen: View {
    @EnvironmentObject private var defaults: DefaultsService

    var body: some View {
        SectionView(mode: .card()) {
            VStack(spacing: 0) {
                ForEach(AppThemeService.Theme.allCases) { theme in
                    Button {
                        defaults.setAppTheme(theme)
                    } label: {
                        TextWithCheckmarkRowView(
                            text: theme.rawValue,
                            isChecked: defaults.appTheme == theme
                        )
                    }
                    .withDivider(if: theme != .system)
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
        .onChange(of: defaults.appTheme, perform: AppThemeService.set)
        .background(Color.swBackground)
        .navigationTitle("Тема приложения")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
#Preview {
    NavigationView {
        AppThemeScreen()
            .environmentObject(DefaultsService())
    }
}
#endif
