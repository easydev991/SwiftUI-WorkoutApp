import SwiftUI

/// Форма нужного размера для отображения картинки
struct SpecificSizeImageRectangle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .aspectRatio(contentMode: .fit)
            .cornerRadius(8)
            .frame(maxWidth: .infinity, maxHeight: 200)
    }
}

extension View {
    func applyProfileImageStyle() -> some View {
        modifier(SpecificSizeImageRectangle())
    }
}
