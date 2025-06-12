import SwiftUI

/// Вьюшка для системной иконки с настройкой фрейма
///
/// - По умолчанию имеет `.symbolVariant(.circle)` и размер `15 * 15`
/// - Цвет - `Color.swAccent`
struct SystemImageWithFrame: View {
    private let systemName: String
    private let size: CGSize
    private let isCircle: Bool
    
    init(
        _ systemName: String,
        size: CGSize = .init(width: 15, height: 15),
        isCircle: Bool = true
    ) {
        self.systemName = systemName
        self.size = size
        self.isCircle = isCircle
    }
    
    var body: some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: size.width, height: size.height)
            .symbolVariant(isCircle ? .circle : .none)
            .foregroundStyle(Color.swAccent)
    }
}
