import SWDesignSystem
import SwiftUI
import SWModels

struct ThemeIconScreen: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                themePicker
                SectionView(header: "Иконка приложения", mode: .regular) {
                    iconsGrid
                        .padding(.top, 12)
                        .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
        .background(Color.swBackground)
        .navigationTitle("Тема и иконка")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var themePicker: some View {
        Menu {
            Picker(
                "",
                selection: .init(
                    get: { defaults.appTheme },
                    set: { defaults.setAppTheme($0) }
                )
            ) {
                ForEach(AppColorTheme.allCases) {
                    Text($0.description).tag($0)
                }
            }
        } label: {
            ListRowView(
                leadingContent: .text("Тема приложения"),
                trailingContent: .textWithChevron(
                    defaults.appTheme.description
                )
            )
        }
    }

    private var iconsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(
                    .adaptive(minimum: 65),
                    spacing: 16,
                    alignment: .leading
                )
            ],
            spacing: 32
        ) {
            ForEach(IconVariant.allCases, id: \.self) { icon in
                Button {
                    Task { await viewModel.setIcon(icon) }
                } label: {
                    makeView(for: icon)
                }
            }
        }
        .accessibilityIdentifier("appIconsGrid")
    }

    private func makeView(for icon: IconVariant) -> some View {
        icon
            .listImage
            .resizable()
            .scaledToFit()
            .frame(width: 64, height: 64)
            .clipShape(.rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.secondary.opacity(0.5), lineWidth: 1)
            }
            .drawingGroup()
            .overlay(alignment: .topTrailing) {
                if icon == viewModel.currentAppIcon {
                    Image(systemName: "checkmark")
                        .symbolVariant(.circle.fill)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .red)
                        .offset(x: 6, y: -6)
                        .transition(.opacity.combined(with: .scale))
                        .accessibilityHidden(true)
                }
            }
            .animation(.default, value: icon == viewModel.currentAppIcon)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ThemeIconScreen()
            .environmentObject(DefaultsService(authHelper: MockAuthHelper()))
    }
}
#endif
