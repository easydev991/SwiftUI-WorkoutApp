import SwiftUI

/// Форма с возможностью настройки радиуса для разных углов
struct RoundedCornerShape: Shape {
    let radius: CGFloat
    let corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#if DEBUG
#Preview {
    Rectangle()
        .foregroundColor(.blue)
        .clipShape(RoundedCornerShape(radius: 20, corners: .bottomLeft))
}
#endif
