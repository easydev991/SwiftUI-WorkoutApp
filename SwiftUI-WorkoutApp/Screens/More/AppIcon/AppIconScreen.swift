import SWDesignSystem
import SwiftUI

struct AppIconScreen: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                SectionView(header: "Текущая иконка", mode: .regular) {
                    makeView(for: viewModel.currentAppIcon.listImage)
                        .padding(.top, 16)
                }
                SectionView(header: "Другие иконки", mode: .regular) {
                    otherIconsGrid
                        .padding(.top, 16)
                }
            }
            .padding([.horizontal, .bottom])
            .padding(.top, 24)
            .animation(.default, value: viewModel.currentAppIcon)
        }
        .background(Color.swBackground)
        .navigationTitle("Иконка приложения")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension AppIconScreen {
    var otherIconsGrid: some View {
        VStack(spacing: 20) {
            let icons = IconVariant.allCases.filter { !$0.isSelected }
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 64), spacing: 32, alignment: .leading)],
                spacing: 32
            ) {
                ForEach(icons, id: \.self) { icon in
                    Button {
                        Task { await viewModel.setIcon(icon) }
                    } label: {
                        makeView(for: icon.listImage)
                    }
                }
            }
        }
    }

    func makeView(for icon: Image) -> some View {
        icon
            .resizable()
            .scaledToFit()
            .frame(width: 64, height: 64)
            .clipShape(.rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.swSeparators, lineWidth: 1)
            }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        AppIconScreen()
    }
}
#endif
