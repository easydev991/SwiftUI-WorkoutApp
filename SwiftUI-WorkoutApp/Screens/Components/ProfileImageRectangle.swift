import SwiftUI

/// Форма для картинки в профиле
struct ProfileImageRectangle: ViewModifier {
    let size: CGSize

    func body(content: Content) -> some View {
        content
            .scaledToFit()
            .cornerRadius(8)
            .frame(width: size.width, height: size.height)
    }
}

extension View {
    func applySpecificSize(_ size: CGSize) -> some View {
        modifier(ProfileImageRectangle(size: size))
    }
}
