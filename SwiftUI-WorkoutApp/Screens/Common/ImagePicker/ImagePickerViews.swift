import SWDesignSystem
import SwiftUI

enum ImagePickerViews {}

extension ImagePickerViews {
    static func makeHeaderString(for count: Int) -> String {
        String.localizedStringWithFormat(
            "photoSectionHeader".localized,
            count
        )
    }

    @ViewBuilder @MainActor
    static func makeSubtitleView(selectionLimit: Int, isEmpty: Bool) -> some View {
        let subtitle = if selectionLimit > 0 {
            isEmpty
                ? String(format: NSLocalizedString("Добавьте фото, максимум %lld", comment: ""), selectionLimit)
                : String(format: NSLocalizedString("Можно добавить ещё %lld", comment: ""), selectionLimit)
        } else {
            "Добавлено максимальное количество фотографий".localized
        }
        Text(subtitle)
            .font(.subheadline)
            .foregroundStyle(Color.swMainText)
            .multilineTextAlignment(.leading)
    }

    @ViewBuilder @MainActor
    static func makeGridView(
        items: [PickedImageView.Model],
        action: @escaping (_ index: Int, _ action: PickedImageView.Action) -> Void
    ) -> some View {
        LazyVGrid(
            columns: .init(
                repeating: .init(
                    .flexible(minimum: UIScreen.main.bounds.size.width * 0.287),
                    spacing: 11
                ),
                count: 3
            ),
            spacing: 12
        ) {
            ForEach(Array(zip(items.indices, items)), id: \.0) { index, model in
                GeometryReader { geo in
                    PickedImageView(
                        model: model,
                        height: geo.size.width,
                        action: { action(index, $0) }
                    )
                }
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(8)
            }
        }
    }
}
